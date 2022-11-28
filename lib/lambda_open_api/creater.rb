require "rspec"
require_relative "resource"
# require_relative "core_path"

module LambdaOpenApi
  module Creater
    # RSpec::Core::DSL.expose_example_group_alias(:lambda_response)
    attr_accessor :resources, :name, :default_event_hash

    def resource(name)
      @resources = []
      @default_event_hash = {}
      @name = name
      yield

      resources.each do |r|
        # p r.http_verb
        # p r.path_data
        CorePath.core_paths[r.path_name] = {} if CorePath.core_paths[r.path_name].nil?
        CorePath.core_paths[r.path_name][r.http_verb] = r.path_data
      end

      # p CorePath.core_paths
      # p "---"
      # p CorePath.core_paths
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
    end

    def example_case(code)
      @res.code = code
      @res.set_path_paramater
      @event_hash = @default_event_hash.dup
      yield
      @res.set_paramaters(body)

      resources << @res
    end

    def set_event(hash)
      @event = hash
    end

    def set_response(data)
      response = LambdaOpenApi::Response.new(data, file_name: "#{name}")
      unless response.data.nil?
        @res.responses[@res.code] = response.template
      end
    end

    def body
      JSON.parse(@event_hash["body"]) rescue @event_hash["body"] || {}
    end

    def set_description(value)
      @res.description = value
    end

    def method_missing(method, *args, &block)
      if method.to_s.split("_").first == "event"
        variable = method.to_s.sub("event_", "")
        @event_hash[variable] = args.first
      end

      if method.to_s.split("_").first(2).join("_") == "default_event"
        variable = method.to_s.sub("default_event_", "")
        @default_event_hash[variable] = args.first
      end
    end

    def lambda_class(klass)
      @lambda_class = klass
    end

    def lambda_method(method_name)
      @lambda_method = method_name
    end

    def run_lambda(&block)
      @lambda_response = described_class.send(@lambda_method || "process", event: @event_hash)
      set_response(@lambda_response["body"] || @lambda_response)

      it "#{@res.path_name}" do
        def lambda_response
          self.class.lambda_response
        end
        instance_eval &block
      end


    end

    def lambda_response
      @lambda_response
    end

  end
end


module Testo
  def fully_formatted(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
    p CorePath.generate_docs unless failure_count > 0
    super
  end
end

RSpec::Core::Notifications::SummaryNotification.prepend(Testo)
RSpec::Core::ExampleGroup.extend(LambdaOpenApi::Creater)
