require "json"
require_relative "router"
require_relative "details"

class LambdaOpenApi::OpenApi
  extend LambdaOpenApi::Router
  extend LambdaOpenApi::Details


  class << self
    def open_api
      details.merge({"paths" => paths})
    end
  end





end
