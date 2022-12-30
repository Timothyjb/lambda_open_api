require "rspec"
require "pry"
require_relative "resource"

module LambdaOpenApi
  module Builder
    attr_accessor :resources, :name, :default_event_hash

    CRUD_VERBS = [:get, :put, :post, :delete]

    def resource(name)
      @resources = []
      @default_event_hash = {}
      @name = name

      yield

      resources.each do |r|
        LambdaOpenApi::Output.core_paths[r.path_name] ||= {}
        LambdaOpenApi::Output.core_paths[r.path_name][r.http_verb] = r.path_data
      end
    end

    # get, put, post, delete
    def crud_method(verb, path)
      @res = LambdaOpenApi::Resource.new
      @res.name = @name
      @res.http_verb = verb
      @res.path_name = path
      @res.interpolate_path_paramater
      @event_hash = @default_event_hash.dup
      @event_hash["requestContext"] = {"httpMethod": verb.upcase}

      yield
    end

    def example_case(code)
      @res.code = code

      yield

      @res.set_request_body(event_hash_body)
      resources << @res
    end

    def run_example(test_name=nil, &block)
      # klass_name = @res.path_name.gsub("{", "_").gsub("}", "_").gsub(":", "_").gsub("/", "_").split.map(&:capitalize).join

      # example_klass = Object.const_set(klass_name,
      #   Class.new do
      #     def self.value
      #       @value
      #     end

      #     def self.set_value(value)
      #       @value = value
      #     end
      #   end
      # )

      # example_klass.set_value(invoke_lambda)
      lambda_response_value = invoke_lambda

      it "#{test_name || @res.path_name}" do
        # @example_klass = example_klass
        @lambda_response_value = lambda_response_value

        def lambda_response
          @lambda_response_value
        #  @example_klass.value
        end

        instance_eval &block
      end
    end

    def event_hash_body
      JSON.parse(@event_hash["body"]) rescue @event_hash["body"] || {}
    end

    def url_params(hash)
      path = @res.path_name.dup
      @event_hash["resource"] = path.gsub(LambdaOpenApi::Resource::PARAMATER_EXPRESION) {|match|
        match = hash[match.delete('{}:').to_sym]
      }
    end

    def invoke_lambda
      url_params({}) if @event_hash["resource"].nil?
      lambda_response = described_class.send(@lambda_method || "process", event: @event_hash, context: OpenStruct.new(aws_request_id: "123"))

      @res.set_response(lambda_response["body"] || lambda_response)

      lambda_response
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
        if @res.respond_to?(string)
          return @res.send("#{string}=", args.first)
        end
      end

      raise NameError.new("NameError (undefined local variable or method `#{method}' for #{self})")
    end

  end
end


