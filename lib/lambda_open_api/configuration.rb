module LambdaOpenApi
  class Configuration
    attr_accessor :file_name, :title, :description, :version, :host, :schemes, :consumes, :produces

    def initialize
      @file_name = "open_api.json"
      @title = "Workflow Settings Api"
      @description = "About this api"
      @version = "1"
      @host = "https://google.com"
      @schemes = ["https"]
      @consumes = ["application/json"]
      @produces = ["application/json"]
    end
  end
end
