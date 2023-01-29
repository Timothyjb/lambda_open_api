module LambdaOpenApi
  class Response
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def json
      {
        "examples": {
          "application/json": @data
        }
      }
    end
  end
end





