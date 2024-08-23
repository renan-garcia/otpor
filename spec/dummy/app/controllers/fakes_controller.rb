class FakesController < ActionController::API
  include Otpor::JsonResponse

  def my_action
    @my_variable = "Hello from FakeController"
  end

  def my_action_custom_status
    RequestStore.store[:status_symbol] = :unprocessable_content
    RequestStore.store[:errors] = [{ message: "Dados inválidos" }]
    default_render
  end

  def my_action_pagination
    @items = TempItem.all.page(1).per(10)
  end
end