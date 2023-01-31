require_relative '../spec_helper'

class MyLambda
  def self.process(event:, context: {})
    key = JSON.parse(event["body"])["key"]
    {
      statusCode: 200,
      body: {name: "Timbo Baggins", email: "tbaggings@onering.com", key: key}
    }
  end
end


RSpec.describe MyLambda do

  resource "Users" do

    get "users/{id}" do
      path_summery "Some very high level details"
      path_description "Some more details about this path"

      example_case "200" do
        parameter({id: 1})

        event_body({
          key: "some_key_value"
        }.to_json)

        event_headers({
          "Api-Key" => "the_api_key"
        })

        run_example do
          expect(lambda_response[:body]).to eq({:email=>"tbaggings@onering.com", :name=>"Timbo Baggins", key: "some_key_value"})
          expect(lambda_response[:statusCode]).to eq(200)
        end
      end
    end

  end
end
