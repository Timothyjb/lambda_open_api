# require_relative "resource"

# module LambdaOpenApi
#   module Router
#     attr_accessor :paths

#     def reset_paths
#       @paths = {}
#     end

#     def resources(name, only: LambdaOpenApi::Resource::METHODS, param: nil)
#       reset_paths if paths.nil?
#       methods = only.is_a?(Array) ? only : [only]

#       only.each do |method|
#         r = LambdaOpenApi::Resource.new(method, name, param || "id")
#         r.set_path_paramater
#         r.set_paramaters
#         r.set_response

#         paths[r.path_name] = {} if paths[r.path_name].nil?
#         paths[r.path_name][r.http_verb] = r.path_data
#       end
#     end

#   end
# end
