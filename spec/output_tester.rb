require './lib/lambda_open_api.rb'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]


class FormatterTester < Minitest::Test
  def test_ask_returns_an_answer
    File.delete("open_api/open_api.json") if File.exist?("open_api/open_api.json")

    `rspec`

    output_file = File.read("open_api/open_api.json")
    expected_file = File.read("spec/lambda_open_api/example.json")

    assert output_file == expected_file
  end

end
