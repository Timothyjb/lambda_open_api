
module LambdaOpenApi
  class Formatter
    @paths = {}

    class << self
      def add_resource(resource)
        @paths[resource.path_name] ||= {}
        @paths[resource.path_name][resource.http_verb] = resource.path_data
      end

      def generate_docs
        open_api = high_level.merge({"paths" => @paths})

        File.open(LambdaOpenApi.configuration.file_name, "w") {|f| f.write(JSON.pretty_generate(open_api) + "\n") }
      end

      def high_level
        {
          "swagger" => "2.0",
          "info" => {
            "title" => LambdaOpenApi.configuration.title,
            "description" => LambdaOpenApi.configuration.description,
            "version" => LambdaOpenApi.configuration.version
          },
          "host" => LambdaOpenApi.configuration.host,
          "schemes" => LambdaOpenApi.configuration.schemes,
          "consumes" => LambdaOpenApi.configuration.consumes,
          "produces" => LambdaOpenApi.configuration.produces
        }
      end
    end
  end
end
