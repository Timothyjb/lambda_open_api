# frozen_string_literal: true
require "json"

require_relative "lambda_open_api/output"
require_relative "lambda_open_api/version"
require_relative "lambda_open_api/configuration"
require_relative "lambda_open_api/builder"

module LambdaOpenApi
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end


# Monkey patching

module LambdaOpenApiNotification
  def fully_formatted(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
    LambdaOpenApi::Output.generate_docs unless failure_count > 0 || errors_outside_of_examples_count > 0
    super
  end
end

RSpec::Core::Notifications::SummaryNotification.prepend(LambdaOpenApiNotification)
RSpec::Core::ExampleGroup.extend(LambdaOpenApi::Builder)
