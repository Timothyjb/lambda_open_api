require_relative "path_parameter"
require_relative "body_parameter"
require_relative "response"

module LambdaOpenApi
  class Resource
    PARAMATER_EXPRESION = /[:\{](\w+)\}?/
    METHOD_MAP = {
      :index => "get",
      :show => "get",
      :update => "put",
      :create => "post",
      :destroy => "delete"
    }
    METHODS = [:index, :show, :create, :update, :destroy]
    METHOD_WITH_PARAM = [:show, :update, :destroy]

    attr_accessor :method, :http_verb, :name, :param, :path_name, :parameters, :responses, :code, :description, :summery

    def initialize()
      @responses = {}
      @parameters = []
    end

    def set_path_paramater
      matches = @path_name.scan PARAMATER_EXPRESION

      if matches.any?

        matches.flatten.each do |match|
          path_param = LambdaOpenApi::PathParameter.new
          path_param.name = match
          @parameters << path_param.to_json
        end
      end

    end

    def set_paramaters(data)
      body = LambdaOpenApi::BodyParameter.new(data, file_name: "#{method}_#{name}")
      unless body.data.nil?
        @parameters << body.template
      end
    end

    def set_response(data)
      response = LambdaOpenApi::Response.new(data, file_name: "#{name}")
      unless response.data.nil?
        @responses["200"] = response.template
      end
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
