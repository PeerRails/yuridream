require "./lib/image_api"
desc "API Routes"
task :routes do
  Images::API.routes.each do |api|
    method = api.route_method.ljust(10)
    path = api.route_path
    puts "     #{method} #{path}"
  end
end
