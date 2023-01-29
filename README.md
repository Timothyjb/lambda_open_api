# LambdaOpenApi

The purpose of this gem is to allow developers to generate Open Api (swagger) file based on the input and output of code that is intended to be ran as an AWS Lambda triggered by an AWS API Gateway.
It hooks into Rspec and generates the an Open Api file after processing your specs.


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lambda_open_api

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lambda_open_api

## Usage

Create an initializer file
```ruby
LambdaOpenApi.configure do |config|
  config.title = "My Example Api"
  config.description = "About this api"
  config.host = "https://my_example.com"
end
```


For this example Lambda
```ruby
require_relative '../spec_helper'

class MyLambda
  def self.process(event:, context: {})
    body = JSON.parse(event["body"])

    # do something useful

    {
      statusCode: 200,
      body: { message: "processed", name: body["name"], email: body["email"] }
    }
  end
end
```

We may write a test like this

```ruby
RSpec.describe MyLambda do

  resource "Users" do

    get "users/{id}" do
      path_summery "Some very high level details"
      path_description "Some more details about this path"

      example_case "200" do
        parameter({id: 1})

        event_body({
          name: "Timbo Baggins",
          email: "tbaggings@hotmail.com"
        }.to_json)

        event_headers({
          "Api-Key" => "the_api_key"
        })

        run_example do
          expect(lambda_response[:body]).to eq({:message => "processed", :email=>"tbaggings@hotmail.com", :name=>"Timbo Baggins"})
          expect(lambda_response[:statusCode]).to eq(200)
        end
      end
    end

  end
end
```

which will output an Open Api file like this
```json
{
  "swagger": "2.0",
  "info": {
    "title": "My Example Api",
    "description": "About this api",
    "version": "1"
  },
  "host": "https://my_example.com",
  "schemes": [
    "https"
  ],
  "consumes": [
    "application/json"
  ],
  "produces": [
    "application/json"
  ],
  "paths": {
    "users/{id}": {
      "get": {
        "tags": [
          "Users"
        ],
        "summary": "Some very high level details",
        "description": "Some more details about this path",
        "consumes": [
          "application/json"
        ],
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "",
            "required": true,
            "type": "integer"
          },
          {
            "name": "body",
            "in": "body",
            "description": "",
            "required": false,
            "schema": {
              "description": "",
              "type": "object",
              "properties": {
                "name": {
                  "type": "string"
                },
                "email": {
                  "type": "string"
                }
              },
              "required": [

              ]
            }
          }
        ],
        "responses": {
          "200": {
            "examples": {
              "application/json": {
                "statusCode": 200,
                "body": {
                  "message": "processed",
                  "name": "Timbo Baggins",
                  "email": "tbaggings@hotmail.com"
                }
              }
            }
          }
        }
      }
    }
  }
}

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lambda_open_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
