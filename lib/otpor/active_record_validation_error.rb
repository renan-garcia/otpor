module Otpor
  module ActiveRecordValidationError
    extend ActiveSupport::Concern
  
    included do
      after_validation :log_validation_errors, if: -> { errors.any? }
    end
  
    private
  
    def log_validation_errors
      error_messages = []
      errors.each do |error|
        error_messages << { attribute: error.attribute, message: error.message, type: error.options.dig(:type) || error.type, entity: self.class.name, entity_id: self.id || 'new record'}
      end
      return unless error_messages.present?

      RequestStore.store[:errors] ||= error_messages
      RequestStore.store[:status_symbol] ||= :unprocessable_content
    end
  end
end