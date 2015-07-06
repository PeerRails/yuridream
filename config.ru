require "./lib/image_api.rb"

require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :get
  end
end

use Rack::Static, :root => 'public',
       :header_rules => [
         # Cache all static files in public caches (e.g. Rack::Cache)
         #  as well as in the browser
         [:all, {'Cache-Control' => 'public, max-age=31536000'}],

         # Provide web fonts with cross-origin access-control-headers
         #  Firefox requires this when serving assets using a Content Delivery Network
         [:fonts, {'Access-Control-Allow-Origin' => '*'}]
       ]

run Images::API
