require "grape"
require "grape-kaminari"
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
        images = Image.reverse(:id).all
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

  end
end
