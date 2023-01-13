require "rspec"
require_relative "resource"

module LambdaOpenApi
  module Builder
    attr_accessor :tested_resources, :name, :default_event_hash

    CRUD_VERBS = [:get, :put, :post, :delete]

    def resource(name)
      @tested_resources = []
      @default_event_hash = {}
      @name = name

      yield

      tested_resources.each do |resource|
        LambdaOpenApi::Formatter.add_resource(resource)
      end
    end

    def method_missing(method, *args, &block)
      if CRUD_VERBS.include?(method)
        crud_method(method.to_s, args.first, &block)
        return
      end

      if method.to_s.split("_").first == "event"
        variable = method.to_s.sub("event_", "")
        return @event_hash[variable] = args.first
      end

      if method.to_s.split("_").first(2).join("_") == "default_event"
        variable = method.to_s.sub("default_event_", "")
        return @default_event_hash[variable] = args.first
      end

      if method.to_s.split("_").first == "path"
        string = method.to_s.sub("path_", "")
        if @current_resource.respond_to?(string)
          return @current_resource.send("#{string}=", args.first)
        end
      end

      raise NameError.new("NameError (undefined local variable or method `#{method}' for #{self})")
    end

    # get, put, post, delete
    def crud_method(verb, path)
      @current_resource = LambdaOpenApi::Resource.new
      @current_resource.name = @name
      @current_resource.http_verb = verb
      @current_resource.path_name = path
      @current_resource.interpolate_path_paramater
      @event_hash = @default_event_hash.dup
      @event_hash["requestContext"] = {"httpMethod": verb.upcase}

      yield

      @current_resource.set_request_body(event_hash_body)
      tested_resources << @current_resource
    end

    def example_case(code)
      @current_resource.code = code

      yield
    end

    def run_example(test_name=nil, &block)
      lambda_response_value = invoke_lambda

      it "#{test_name || @current_resource.path_name}" do
        @lambda_response_value = lambda_response_value

        def lambda_response
          @lambda_response_value
        end

        instance_eval &block
      end
    end

    def event_hash_body
      JSON.parse(@event_hash["body"]) rescue @event_hash["body"] || {}
    end

    def url_params(hash)
      path = @current_resource.path_name.dup
      @event_hash["resource"] = path.gsub(LambdaOpenApi::Resource::PARAMATER_EXPRESION) {|match|
        match = hash[match.delete('{}:').to_sym]
      }
    end

    def invoke_lambda
      url_params({}) if @event_hash["resource"].nil?
      lambda_response = described_class.send(@lambda_method || "process", event: @event_hash, context: lambda_context)

      @current_resource.set_response(lambda_response["body"] || lambda_response)

      lambda_response
    end

    def lambda_context
      OpenStruct.new(aws_request_id: "123")
    end

  end
end


