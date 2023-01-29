require_relative "path_parameter"
require_relative "body_parameter"
require_relative "response"

module LambdaOpenApi
  class Action
    PARAMATER_EXPRESION = /[:\{](\w+)\}?/

    attr_accessor :method, :http_verb, :name, :param, :path_name, :parameters, :responses, :code, :description, :summery

    def initialize(name:, http_verb:, path_name:)
      @responses = {}
      @parameters = []
      @name = name
      @http_verb = http_verb
      @path_name = path_name

      interpolate_path_paramater
    end

    def interpolate_path_paramater
      matches = @path_name.scan PARAMATER_EXPRESION

      return unless matches.any?

      matches.flatten.each do |match|
        @parameters << LambdaOpenApi::PathParameter.new(name: match).json
      end
    end

    def set_request_body(data)
      @parameters << LambdaOpenApi::BodyParameter.new(data).json
    end

    def set_response(data)
      @responses["200"] = LambdaOpenApi::Response.new(data).json
    end

    def action_json
      {
        "tags"=> [titleize(@name)],
        "summary"=> @summery,
        "description"=> @description,
        "consumes"=> [
          "application/json"
        ],
        "produces"=> [
          "application/json"
        ],
        "parameters" => @parameters,
        "responses" => @responses
      }
    end


    def titleize(string)
      string.to_s.split("_").map{|word| word.capitalize}.join(" ")
    end

  end

end
