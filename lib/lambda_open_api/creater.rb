require "rspec"
require_relative "resource"

module LambdaOpenApi
  module Creater
    attr_accessor :resources, :name, :default_event_hash

    def resource(name)
      @resources = []
      @default_event_hash = {}
      @name = name
      yield

      resources.each do |r|
        CorePath.core_paths[r.path_name] = {} if CorePath.core_paths[r.path_name].nil?
        CorePath.core_paths[r.path_name][r.http_verb] = r.path_data
      end
    end

    def get(path)
      set_response_variable("get", path)
      yield
    end

    def put(path)
      set_response_variable("put", path)
      yield
    end


    def post(path)
      set_response_variable("post", path)
      yield
    end

    def delete(path)
      set_response_variable("delete", path)
      yield
    end

    def set_response_variable(verb, path)
      @res = LambdaOpenApi::Resource.new
      @res.name = name
      @res.http_verb = verb
      @res.path_name = path
      # p path
      @res.set_path_paramater
      @event_hash = @default_event_hash.dup
      @event_hash["requestContext"] = {}
      @event_hash["requestContext"]["httpMethod"] = verb.upcase
    end

    def example_case(code)
      @res.code = code
      yield
      @res.set_paramaters(body)
      resources << @res
    end


    def body
      JSON.parse(@event_hash["body"]) rescue @event_hash["body"] || {}
    end

    def path_description(value)
      @res.description = value
    end

    def path_summery(value)
      @res.summery = value
    end

    def method_missing(method, *args, &block)
      if method.to_s.split("_").first == "event"
        variable = method.to_s.sub("event_", "")
        return @event_hash[variable] = args.first
      end

      if method.to_s.split("_").first(2).join("_") == "default_event"
        variable = method.to_s.sub("default_event_", "")
        return @default_event_hash[variable] = args.first
      end

      raise NameError.new("NameError (undefined local variable or method `#{method}' for #{self})")
    end


    def url_params(hash)
      path = @res.path_name.dup
      @event_hash["resource"] = path.gsub(LambdaOpenApi::Resource::PARAMATER_EXPRESION) {|match|
        match = hash[match.delete('{}:').to_sym]
      }
    end

    def lambda_method(method_name)
      @lambda_method = method_name
    end

    def run_lambda(test_name=nil, &block)
      url_params({}) if @event_hash["resource"].nil?
      @lambda_response = described_class.send(@lambda_method || "process", event: @event_hash)
      @res.set_response(@lambda_response["body"] || @lambda_response)

      it "statusCode equals #{@res.code}" do
        expect(self.class.lambda_response[:statusCode].to_s).to eq self.class.res.code
      end

      it "#{test_name || @res.path_name}" do
        def lambda_response
          self.class.lambda_response
        end
        instance_eval &block
      end
    end

    def lambda_response
      @lambda_response
    end
    def res
      @res
    end

  end
end


module LambdaOpenApiNotification
  def fully_formatted(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
    CorePath.generate_docs unless failure_count > 0 || errors_outside_of_examples_count > 0
    super
  end
end

RSpec::Core::Notifications::SummaryNotification.prepend(LambdaOpenApiNotification)
RSpec::Core::ExampleGroup.extend(LambdaOpenApi::Creater)
