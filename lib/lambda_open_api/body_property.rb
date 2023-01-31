module LambdaOpenApi
  class BodyProperty

    attr_accessor :props

    def generate(hash)
      @props = {}

      hash.each do |key, value|
        if value.is_a?(Hash)
          hash = LambdaOpenApi::BodyProperty.new
          hash.generate(value)

          props[key.to_s] = {
            "type"=>  "object",
            "properties"=> hash.props
          }
        elsif value.is_a?(Array)
          item_props = {}

          value.each do |item|
            hash = LambdaOpenApi::BodyProperty.new
            hash.generate(item)
            item_props.merge!(hash.props)
          end

          props[key.to_s] = {
            "type"=>  "array",
            "items"=> {
              "type" => "object",
              "properties" => item_props
            }
          }
        else
          props[key.to_s] = {
            "type"=>  value_type(value)
          }
        end
      end
    end

    def value_type(value)
      klass = value.class.name.downcase
      return "boolean" if klass == "trueclass" || klass == "falseclass"
      klass
    end

  end
end


