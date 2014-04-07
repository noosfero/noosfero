module API
  module V1
  class Comments < Grape::API

    before { authenticate! }
 
    resource :articles do
      #FIXME make the pagination
      #FIXME put it on environment context
      get ":id/comments" do
        present Article.find(params[:id]).comments, :with => Entities::Comment
      end
 
      get ":id/comments/:comment_id" do
        present Article.find(params[:id]).comments.find(params[:comment_id]), :with => Entities::Comment
      end
 
    end
 
  end
  end
end
