module API
  module V1
    class Users < Grape::API
   
      before { detect_stuff_by_domain }
      before { authenticate! }

      resource :users do

        #FIXME make the pagination
        #FIXME put it on environment context
        get do
          present environment.users, :with => Entities::User
        end

        get ":id" do
          present environment.users.find(params[:id]), :with => Entities::User
        end

      end

    end
  end
end
