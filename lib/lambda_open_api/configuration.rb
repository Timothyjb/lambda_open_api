module LambdaOpenApi
  class Configuration
    attr_accessor :file_name, :title, :description, :version, :host, :schemes, :consumes, :produces, :file_sets

    def initialize
      @file_name = "open_api/open_api.json"
      @title = "Workflow Settings Api"
      @description = "About this api"
      @version = "1"
      @host = "https://google.com"
      @schemes = ["https"]
      @consumes = ["application/json"]
      @produces = ["application/json"]
      @file_sets = []
    end
  end
end
