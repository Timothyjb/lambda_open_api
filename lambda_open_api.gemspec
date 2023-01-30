# frozen_string_literal: true

require_relative "lib/lambda_open_api/version"

Gem::Specification.new do |spec|
  spec.name = "lambda_open_api"
  spec.version = LambdaOpenApi::VERSION
  spec.authors = ["Timothyjb"]
  spec.email = ["timothyjbarkley@gmail.com"]

  spec.summary = "A DSL for generating OpenAPI (swagger) files for APIs using AWS Lambda"
  spec.description = "This gem is a light weight DSL that works with rspec to allow developers to generate an OpenAPI (swagger) file based an AWS Lambda invoked by API Gateway. It works by writing a simple unit test for your lambda's code. When the test is executed, the input event and returned response are captured and used to build an OpenAPI file."
  spec.homepage = "https://github.com/Timothyjb/lambda_open_api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Timothyjb/lambda_open_api"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "rspec"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
