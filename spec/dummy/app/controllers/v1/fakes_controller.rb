class V1::FakesController < ActionController::API
  include Otpor::JsonResponse

  def my_action
    @my_variable = "Hello from FakeController"
  end
end