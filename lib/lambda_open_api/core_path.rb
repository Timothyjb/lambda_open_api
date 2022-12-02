
class CorePath
  @core_paths = {}

  def self.core_paths
    @core_paths
  end

  def self.generate_docs
    open_api = high_level.merge({"paths" => @core_paths})

    File.open(LambdaOpenApi.configuration.file_name, "w") {|f| f.write(JSON.pretty_generate(open_api)) }
  end

  def self.high_level
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
