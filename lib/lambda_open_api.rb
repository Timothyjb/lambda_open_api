# frozen_string_literal: true
require "json"

require_relative "lambda_open_api/core_path"
require_relative "lambda_open_api/version"
require_relative "lambda_open_api/router"
require_relative "lambda_open_api/configuration"

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
