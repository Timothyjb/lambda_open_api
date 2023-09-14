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
      @event.request_context = {"httpMethod" => verb.upcase, "http" => {"method" => verb.upcase}}
      @event.path = path
      yield

      @action.set_request_body(JSON.parse(@event.body))
      actions << @action
    end

    def example_case(code)
      @action.code = code

      yield
    end

    def run_example(test_name=nil, &block)
      klass = create_class
      test_name ||= "#{@action.http_verb} #{@action.path_name}"

      it "#{test_name}" do
        @klass = klass
        def lambda_response
          @lambda_response ||= @klass.invoke
        end

        instance_eval &block
      end
    end


    def parameter(hash)
      path = @action.path_name.dup
      @event.resource = path.gsub(LambdaOpenApi::Action::PARAMATER_EXPRESION) {|match|
        match = hash[match.delete('{}:').to_sym]
      }
      @event.path_parameters = hash.inject({}) {|hash, (key, value)| hash[key.to_s] = value; hash}
    end

    def invoke_lambda
      parameter({}) if @event.resource.nil?

      invokcation = LambdaOpenApi::Invoker.new(klass: described_class, method: "process", event: @event.json, context: lambda_context)

      invokcation.response_body
    end

    def lambda_context
      OpenStruct.new(aws_request_id: "123")
    end

    def create_class
      dynamic_name = "ClassName#{rand(10000)}"
      klass = Object.const_set(dynamic_name, Class.new do
        def self.set_event(event)
          @event = event
        end

        def self.event
          @event
        end

        def self.set_described_class(klass)
          @klass = klass
        end

        def self.invoke
          invokcation = LambdaOpenApi::Invoker.new(klass: @klass, method: "process", event: @event.json, context: OpenStruct.new(aws_request_id: "123"))
          @action.set_response(invokcation.response_body)
          invokcation.response
        end
        def self.set_action(action)
          @action = action
        end
      end)

      klass.set_event(@event)
      klass.set_action(@action)
      klass.set_described_class(described_class)
      klass
    end

  end
end


