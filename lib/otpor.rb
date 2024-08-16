# frozen_string_literal: true

require "request_store"
require_relative "otpor/version"
require_relative "otpor/json_response"
require_relative "otpor/active_record_validation_error"

module Otpor
  class Engine < ::Rails::Engine
    initializer "otpor.load_view_paths" do |app|
      ActiveSupport.on_load(:action_controller) do
        append_view_path Otpor::Engine.root.join("lib", "otpor", "templates")
      end
    end
  end
end
