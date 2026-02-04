class FakesController < ActionController::API
  include Otpor::JsonResponse

  def my_action
    @my_variable = "Hello from FakeController"
  end

  def my_action_custom_status
    RequestStore.store[:status_symbol] = :unprocessable_content
    RequestStore.store[:errors] = [{ message: "Invalid data" }]
    default_render
  end

  def my_action_pagination
    @items = TempItem.all.page(1).per(10)
  end

  def my_action_custom_pagination
    @pagination = {
      pagination: {
        total_pages: 5,
        total_count: 50,
        current_page: 2,
        next_page: 3,
        prev_page: 1,
        per_page: 10
      }
    }
  end

  def my_action_custom_api_version
    @api_version = { api_version: "v2" }
  end

  def my_action_custom_meta
    @pagination = {
      pagination: {
        total_pages: 3,
        total_count: 30,
        current_page: 1,
        next_page: 2,
        prev_page: nil,
        per_page: 10
      }
    }
    @api_version = { api_version: "v3" }
  end
end