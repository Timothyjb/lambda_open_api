# require_relative "to_process"
# require_relative "resource"
# require_relative "creater"
# require "json"

# extend LambdaOpenApi::Creater


# resource "Users" do

#   lambda_class  LambdaOpenApi::ToProcess
#   lambda_method "process"

#   get "users/{id}" do
#     example "200" do
#       let(:id) {"1"}

#       event_body({
#         values: "",
#         workflow_id: "1",
#         workflow_uuid: "abcd"
#       }.to_json)

#       event_headers({
#         "Api-Key" => "the_api_key"
#       })

#       run_lambda
#     end

#     example "404" do
#       event_body({
#         values: ""
#       }.to_json)

#       event_headers({
#         "Api-Key" => "the_api_key"
#       })

#       run_lambda
#     end
#   end

#   put "users/{id}" do
#     example "200" do
#       event_body({
#         values: "",
#         workflow_id: "1",
#         workflow_uuid: "abcd"
#       }.to_json)

#       event_headers({
#         "Api-Key" => "the_api_key"
#       })

#       run_lambda
#     end
#   end

# end
