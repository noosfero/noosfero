module API
  module V1
  class Comments < Grape::API
 
    resource :articles do

      get ":id/comments" do
        Article.find(params[:id]).comments
      end
 
      get ":id/comments/:comment_id" do
        Article.find(params[:id]).comments.find(params[:comment_id])
      end
 
    end
 
  end
  end
end
