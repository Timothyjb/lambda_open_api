require_relative '../spec_helper'
require_relative '../../lib/lambda_open_api/to_process'

RSpec.describe LambdaOpenApi::ToProcess do

  resource "Users" do
    get "users/{id}" do
      path_description "yoyoyoyo"
      path_summery "some ther summery"

      example_case "200" do
        url_params({id: 1})

        event_body({
          values: "",
          workflow_id: "1",
          workflow_uuid: "abcd"
        }.to_json)

        event_headers({
          "Api-Key" => "the_api_key"
        })

        run_lambda do
          expect(lambda_response[:body]).to eq({:email=>"tim@tim.com", :name=>"tim"})
        end
      end
    end

    get "users" do
      example_case "200" do
        event_body({
          workflow_uuid: "abcd"
        }.to_json)

        event_headers({
          "Api-Key" => "the_api_key"
        })

        run_lambda do
          expect(lambda_response[:body]).to eq({:email=>"tim@tim.com", :name=>"tim"})
        end
      end
    end


  end

end


