require "./lib/image_api.rb"

Rack::Server.start :app => Images::API, :Host => "0.0.0.0", :Port => "9292"
