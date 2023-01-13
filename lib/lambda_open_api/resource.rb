require_relative "path_parameter"
require_relative "body_parameter"
require_relative "response"

module LambdaOpenApi
  class Resource
    PARAMATER_EXPRESION = /[:\{](\w+)\}?/

    attr_accessor :method, :http_verb, :name, :param, :path_name, :parameters, :responses, :code, :description, :summery

    def initialize()
      @responses = {}
      @parameters = []
    end

    def interpolate_path_paramater
      matches = @path_name.scan PARAMATER_EXPRESION

      return unless matches.any?

      matches.flatten.each do |match|
        path_param = LambdaOpenApi::PathParameter.new
        path_param.name = match
        @parameters << path_param.to_json
      end
    end

    def set_request_body(data)
      body = LambdaOpenApi::BodyParameter.new(data)
      return if body.data.nil?
      @parameters << body.template
    end

    def set_response(data)
      @responses["200"] = LambdaOpenApi::Response.new(data).response
    end

    def path_data
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
