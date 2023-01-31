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

  resource "Use Cases" do

    post "includes/objects/and/arrays" do
      example_case "200" do
        event_body(
          {
            key: "abcd",
            object: {key_1: "value_1", key_2: "value_2"},
            array: [{item_1: "value_1", item_2: "value_2"}]
          }.to_json)

        event_headers({
          "Api-Key" => "the_api_key"
        })
        run_example do
          expect(lambda_response[:body]).to eq({:email=>"tbaggings@onering.com", :name=>"Timbo Baggins", key: "abcd"})
        end
      end
    end
  end
end
