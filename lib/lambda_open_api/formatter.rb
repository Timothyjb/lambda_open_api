require 'fileutils'

module LambdaOpenApi
  class Formatter
    @paths = {}

    class << self
      def add_request(resource)
        @paths[resource.path_name] ||= {}
        @paths[resource.path_name][resource.http_verb] = resource.action_json
      end

      def generate_docs




        if uses_file_sets?
          LambdaOpenApi.configuration.file_sets.each do |file_set|
            LambdaOpenApi.configuration.host = file_set[:host]

            open_api = high_level_structure.merge({"paths" => @paths})

            create_file(file_set[:file_name], open_api)
          end
        else
          open_api = high_level_structure.merge({"paths" => @paths})
          create_file(LambdaOpenApi.configuration.file_name, open_api)
        end
      end

      def high_level_structure
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

      def uses_file_sets?
        LambdaOpenApi.configuration.file_sets&.is_a?(Array) &&
        LambdaOpenApi.configuration.file_sets.any?
      end

      def create_file(file_name, file_content)
        dirname = File.dirname(file_name)
        p dirname
        unless File.directory?(dirname)
          p 'to create'
          p FileUtils.mkdir_p(dirname)
        end


        File.open(file_name, "w") {|f| f.write(JSON.pretty_generate(file_content) + "\n") }
      end
    end
  end
end
