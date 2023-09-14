module LambdaOpenApi
  class Event
    attr_accessor :resource,
                  :path,
                  :http_method,
                  :request_context,
                  :headers,
                  :multi_value_headers,
                  :query_string_parameters,
                  :multi_value_query_string_parameters,
                  :path_parameters,
                  :stage_variables,
                  :body,
                  :is_base64_encoded

    def initialize
      @body = "{}"
    end

    def json
      {
        "resource" => resource,
        "path" => path,
        "httpMethod" => http_method,
        "requestContext" => request_context,
        "headers" => headers,
        "multiValueHeaders" => multi_value_headers,
        "queryStringParameters" => query_string_parameters,
        "multiValueQueryStringParameters" => multi_value_query_string_parameters,
        "pathParameters" => path_parameters,
        "stageVariables" => stage_variables,
        "body" => body,
        "isBase64Encoded" => is_base64_encoded,
        "rawPath": path
      }
    end
  end
end
