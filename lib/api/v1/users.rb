module API
  module V1
    class Users < Grape::API
   
      before { authenticate! }
  
      resource :users do
  
        #FIXME make the pagination
        #FIXME put it on environment context
        get do
          Users.all
        end
   
        get ":id" do
          present Article.find(params[:id]).comments.find(params[:comment_id]), :with => Entities::User
        end
  
      end
   
    end
  end
end
