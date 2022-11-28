module LambdaOpenApi
  module Details

    attr_accessor :title, :description, :version, :host, :schemes, :consumes, :produces

    def schemes
      @schemes || ["https"]
    end

    def consumes
      @consumes || ["application/json"]
    end

    def produces
      @produces || ["application/json"]
    end

    def details
      {
        "swagger" => "2.0",
        "info" => {
          "title" => title,
          "description" => description,
          "version" => version
        },
        "host" => host,
        "schemes" => schemes,
        "consumes" => consumes,
        "produces" => produces
      }
    end

  end
end



