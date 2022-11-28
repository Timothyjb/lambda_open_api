require_relative "body_property.rb"

module LambdaOpenApi
  class BodyParameter
    attr_accessor :data

    def initialize(data = nil, file_name: nil)
      @file_name = file_name

      @data = data
      if data.nil? && File.exists?("lib/lambda_open_api/examples/requests/#{file_name}.json")
        json = File.open("lib/lambda_open_api/examples/requests/#{file_name}.json").read
        @data = JSON.parse(json)
      end
    end

    def template
      hash = LambdaOpenApi::BodyProperty.new
      hash.generate(@data)
      {
        "name"=> "body",
        "in"=> "body",
        "description"=> "",
        "required"=> false,
        "schema"=> {
          "description"=> "",
          "type"=> "object",
          "properties"=> hash.props,
          "required"=> []
        }
      }
    end

  end
end



