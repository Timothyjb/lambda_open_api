require_relative "details"

class CorePath
  extend LambdaOpenApi::Details
  @core_paths = {}

  def self.core_paths
    @core_paths
  end

  def self.generate_docs
    self.title = "Workflow Settings Api"
    self.description = "About this api"
    self.version = "1"
    self.host = "https://google.com"


    open_api = details.merge({"paths" => @core_paths})

    # puts JSON.pretty_generate(open_api)
  end
end
