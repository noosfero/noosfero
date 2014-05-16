module API
  module V1
    class Users < Grape::API

      before { authenticate! }

      resource :users do

        #FIXME make the pagination
        #FIXME put it on environment context
        get do
          present User.all, :with => Entities::User
        end

        get ":id" do
          present User.find(params[:id]), :with => Entities::User
        end

      end

    end
  end
end
