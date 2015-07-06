require "grape"
require "grape-kaminari"
require './lib/ZipFileGenerator'
require "./lib/Image"

module Images
  class API < Grape::API
    include Grape::Kaminari
    format :json
    content_type :json, 'application/json'
    prefix :api

    resource :images do

      desc "Return a list of images"
      paginate per_page: 20, offset: 0
      get do 
        images = Image.reverse(:id).naked.all
        paginate(Kaminari.paginate_array(images))
      end

      desc "Return a number of pages"
      get :pages do 
        pages = Image.count(:id) / 20     
        {pages: pages + 1}
      end

    end

    resource :image do

      params do
        requires :id, type: Integer
      end

      desc "Return an image record"
      get do
        Image.where(id: params[:id])
      end

    end

    resource :archive do

      desc "Give url to zip archive and create if it doesnt exist"
      get do 
        path = Dir.pwd + "/archives"
        azip = Dir.glob(File.join(path, '*.*')).max { |a,b| File.ctime(a) <=> File.ctime(b) }
        unless azip.nil?
          {zip: "archives/#{azip.split("/").last}"}
        else
          {error: "no archives yet"}
        end
      end
    end

  end
end
