# frozen_string_literal: true

require_relative "lib/otpor/version"

Gem::Specification.new do |spec|
  spec.name          = "otpor"
  spec.version       = Otpor::VERSION
  spec.authors       = ["Renan Garcia"]
  spec.email         = ["renan.almeida.garcia@icloud.com"]

  spec.summary       = "Otpor: JSON Response Concern"
  spec.description   = "This gem includes a concern that defines a default Jbuilder template for controller actions that include it, rendering consistent JSON responses."
  spec.homepage      = "https://github.com/renan-garcia/otpor"
  spec.license       = "MIT"

  spec.metadata = {
    "changelog_uri" => "https://github.com/renan-garcia/otpor/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/renan-garcia/otpor/",
    "rubygems_mfa_required" => "true"
  }

  spec.files         = Dir["lib/**/*"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jbuilder", ">= 2.12.0"
  spec.add_dependency "kaminari", ">= 1.2.2"
  spec.add_dependency "rails", ">= 5.0.0"
  spec.add_dependency "request_store", ">= 1.7"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
end
