require_relative "body_property.rb"

module LambdaOpenApi
  class BodyParameter
    attr_accessor :data

    def initialize(data = nil)
      @data = data
    end

    def json
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



