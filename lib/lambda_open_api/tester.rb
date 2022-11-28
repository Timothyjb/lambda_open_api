require_relative "details"
require_relative "resource"
require_relative "creater"
require "json"

extend LambdaOpenApi::Creater
extend LambdaOpenApi::Details


@core_paths = {}


require_relative "../../spec/lambda_open_api/to_process_spec.rb"
require_relative "test_file_2"
require_relative "test_file"


self.title = "Workflow Settings Api"
self.description = "About this api"
self.version = "1"
self.host = "https://google.com"


open_api = details.merge({"paths" => @core_paths})

puts JSON.pretty_generate(open_api)
