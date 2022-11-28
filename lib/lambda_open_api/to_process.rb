module LambdaOpenApi
  class ToProcess
    def self.process(event:, context: {})
      {
        statusCode: 200,
        body: {name: "tim", email: "tim@tim.com"}
      }
    end
  end
end
