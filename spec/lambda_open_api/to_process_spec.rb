require_relative '../spec_helper'
require_relative '../../lib/lambda_open_api/to_process'
require_relative '../../lib/lambda_open_api/creater'

RSpec.describe LambdaOpenApi::ToProcess do

  # @core_paths = {}
  resource "Users" do

    get "users/{id}" do
      example_case "200" do
        let(:id) {"1"}

        event_body({
          values: "",
          workflow_id: "1",
          workflow_uuid: "abcd"
        }.to_json)

        event_headers({
          "Api-Key" => "the_api_key"
        })

        run_lambda do
          expect(lambda_response[:statusCode]).to eq(200)
        end
      end
    end

    get "users" do
      example_case "200" do
        let(:id) {"1"}

        event_body({
          workflow_uuid: "abcd"
        }.to_json)

        event_headers({
          "Api-Key" => "the_api_key"
        })

        run_lambda do
          expect(lambda_response[:statusCode]).to eq(200)
        end
      end
    end


  end

end


