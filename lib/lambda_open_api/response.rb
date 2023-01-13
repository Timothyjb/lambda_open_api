module LambdaOpenApi
  class Response
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def response
      {
        "examples": {
          "application/json": @data
        }
      }
    end
  end
end





