require "rspec"
require_relative "action"
require_relative "event"

module LambdaOpenApi
  module Builder
    attr_accessor :actions, :name, :default_event_hash

    CRUD_VERBS = [:get, :put, :post, :delete]

    def resource(name)
      @actions = []
      @default_event = LambdaOpenApi::Event.new
      @name = name

      yield

      actions.each do |request|
        LambdaOpenApi::Formatter.add_request(request)
      end
    end

    def method_missing(method, *args, &block)
      if CRUD_VERBS.include?(method)
        crud_verb(method.to_s, args.first, &block)
        return
      end

      if method.to_s.start_with?("event")
        variable = method.to_s.sub("event_", "")
        return @event.send("#{variable}=", args.first)
      end

      if method.to_s.start_with?("default_event")
        variable = method.to_s.sub("default_event_", "")
        return @default_event.send("#{variable}=", args.first)
      end

      if method.to_s.start_with?("path")
        string = method.to_s.sub("path_", "")
        if @action.respond_to?(string)
          return @action.send("#{string}=", args.first)
        end
      end

      raise NameError.new("NameError (undefined local variable or method `#{method}' for #{self})")
    end

    # get, put, post, delete
    def crud_verb(verb, path)
      @action = LambdaOpenApi::Action.new(name: @name, http_verb: verb, path_name: path)
      @event = @default_event.dup
      @event.request_context = {"httpMethod" => verb.upcase}

      yield

      @action.set_request_body(JSON.parse(@event.body))
      actions << @action
    end

    def example_case(code)
      @action.code = code

      yield
    end

    def run_example(test_name=nil, &block)
      lambda_response_value = invoke_lambda
      @action.set_response(lambda_response_value)

      it "#{test_name || @action.path_name}" do
        @lambda_response_value = lambda_response_value

        def lambda_response
          @lambda_response_value
        end

        instance_eval &block
      end
    end


    def parameter(hash)
      path = @action.path_name.dup
      @event.resource = path.gsub(LambdaOpenApi::Action::PARAMATER_EXPRESION) {|match|
        match = hash[match.delete('{}:').to_sym]
      }
    end

    def invoke_lambda
      parameter({}) if @event.resource.nil?

      invokcation = LambdaOpenApi::Invoker.new(klass: described_class, method: "process", event: @event.json, context: lambda_context)

      invokcation.response_body
    end

    def lambda_context
      OpenStruct.new(aws_request_id: "123")
    end

  end
end


