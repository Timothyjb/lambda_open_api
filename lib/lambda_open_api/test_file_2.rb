require_relative "to_process"

resource "Orders" do
  lambda_class  LambdaOpenApi::ToProcess
  lambda_method "process"

  default_event_body({
    workflow_id: "1"
  }.to_json)

  get "orders" do
    example "200" do

      event_headers({
        "Api-Key" => "the_api_key"
      })

      run_lambda
    end
  end

  put "orders/{id}" do
    example "200" do
      event_body({
        name: "test"
      }.to_json)

      event_headers({
        "Api-Key" => "the_api_key"
      })

      run_lambda
    end

  end

end
