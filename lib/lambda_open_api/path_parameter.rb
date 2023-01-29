module LambdaOpenApi
  class PathParameter
    attr_accessor :name, :in, :description, :required, :type

    def initialize(name: nil)
      @name = name
    end

    def json
      {
        "name"=> @name || "id",
        "in"=> @in || "path",
        "description"=> @description || "",
        "required"=> @required || true,
        "type"=> @type || "integer"
      }
    end
  end
end



