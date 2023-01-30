# LambdaOpenApi

This gem is a light weight DSL that works with rspec to allow developers to generate an OpenAPI (swagger) file based an AWS Lambda invoked by API Gateway. It works by writing a simple unit test for your lambda's code. When the test is executed, the input event and returned response are captured and used to build an OpenAPI file. 

## Installation

Add to your gem file:
```ruby
group :test do
  gem 'rspec'
  gem 'lambda_open_api'
end
```
    
Create an initializer file to configure the gem. 
```ruby
LambdaOpenApi.configure do |config|
  config.file_name = "open_api.json"
  config.title = "My Example Api"
  config.description = "About this api"
  config.version = "1"
  config.host = "https://my_example_api.com"
  config.schemes = ["https"]
  config.consumes = ["application/json"] 
  config.produces = ["application/json"]
end
```

Include the gem in your spec hepler file `spec/spec_helper.rb` or any file that gets loaded before rspec is ran. 
```ruby
require "lambda_open_api"

RSpec.configure do |config|
  # ...
  # the rest of your normal config
  #...
end
```

That's it!

## Usage

Let's say we have a lmabda that looks something like this.
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

We can write a spec file like this:

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

Run rspec 
```bash
rspec
```

An Open Api file will be generated and saved that looks like this:
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

From https://editor-next.swagger.io/
<img width="853" alt="Screen Shot 2023-01-30 at 9 42 18 AM" src="https://user-images.githubusercontent.com/9610694/215508235-c0edfadb-6df1-4cc5-83ef-43fdecc9dc34.png">

<img width="851" alt="Screen Shot 2023-01-30 at 9 42 04 AM" src="https://user-images.githubusercontent.com/9610694/215508248-b852cff0-2bf3-40ae-a601-43c0e6173831.png">

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Timothyjb/lambda_open_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
