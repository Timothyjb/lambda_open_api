module LambdaOpenApi
  class Invoker

    attr_accessor :response

    def initialize(klass:, method:, event:, context:)
      @response = klass.send(method || "process", event: event, context: context)
    end

    def response_body
      response["body"] || response
    end

  end
end
