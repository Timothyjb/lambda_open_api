module LambdaOpenApi
  class Response
    attr_accessor :data

    def initialize(data = nil, file_name: nil)
      @data = data
      if data.nil? && !file_name.nil? && File.exists?("lib/lambda_open_api/examples/responses/#{file_name}.json")
        json = File.open("lib/lambda_open_api/examples/responses/#{file_name}.json").read
        @data = JSON.parse(json)
      end
    end

    def template
      {
        "examples": {
          "application/json": @data
        }
      }
    end
  end
end





