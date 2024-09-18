module Otpor
  module JsonResponse
    extend ActiveSupport::Concern

    included do
      before_action :capture_initial_instance_variables
      around_action :rescue_exceptions
      rescue_from ActionView::MissingTemplate, with: :handle_missing_partial
    end

    def handle_missing_partial; end

    def default_render(*args)
      super and return unless request.format.json?

      @errors ||= RequestStore.store[:errors] || nil
      @notes ||= nil

      @status_symbol = RequestStore.store[:status_symbol] if RequestStore.store[:status_symbol]
      @status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[@status_symbol] if @status_symbol
      @status_code ||= response.status
      @status = {
        name: http_status_name(@status_code),
        code: @status_code,
        type: http_status_type(@status_code)
      }

      partial_exists = lookup_context.exists?("#{controller_path}/#{action_name}", [], true)

      @data_partial ||= "#{controller_path}/#{action_name}" if @status[:type].eql?("Success") && partial_exists

      @instance_variables = capture_new_instance_variables

      @meta ||= infer_meta

      render template: "shared/response", formats: :json, status: @status_code
    end

    private

    def http_status_name(status_code)
      Rack::Utils::HTTP_STATUS_CODES[status_code]
    end

    def rescue_exceptions
      yield
    rescue StandardError => e
      @status_code = determine_status_code(e)
      @status = {
        name: http_status_name(@status_code),
        code: @status_code,
        type: http_status_type(@status_code)
      }
      @errors ||= RequestStore.store[:errors] || nil
      @exception_log = [{ message: e.message, backtrace: e.backtrace[0, 5] }] if Rails.env.development?
      render template: "shared/response", formats: :json, status: @status_code
    end

    def determine_status_code(exception)
      case exception
      when ActiveRecord::RecordNotFound
        404
      when ActionController::RoutingError, ActionController::UnknownFormat
        404
      when ActiveRecord::RecordInvalid, ActionController::ParameterMissing
        422
      else
        500
      end
    end

    def http_status_type(status_code)
      case status_code
      when 100..199
        "Informational"
      when 200..299
        "Success"
      when 300..399
        "Redirection"
      when 400..499
        "Client Error"
      when 500..599
        "Server Error"
      else
        "Unknown"
      end
    end

    def capture_initial_instance_variables
      @initial_instance_variables = instance_variables
    end

    def capture_new_instance_variables
      current_instance_variables = instance_variables
      new_vars = current_instance_variables - @initial_instance_variables
      new_vars -= %i[@initial_instance_variables @errors @notes @data_partial @status
                     @_response_body @new_instance_variables]
      new_instance_vars = {}
      new_vars.each do |var|
        new_instance_vars[var] = instance_variable_get(var)
      end
      new_instance_vars
    end

    def infer_meta
      @instance_variables.each do |key, value|
        next unless value.respond_to?(:total_pages)

        return {
          pagination: {
            total_pages: value.total_pages,
            total_count: value.total_count,
            current_page: value.current_page,
            next_page: value.next_page,
            prev_page: value.prev_page,
            per_page: value.limit_value
          }
        }
      end

      nil
    end
  end
end
