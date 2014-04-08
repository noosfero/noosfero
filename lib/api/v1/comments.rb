module API
  module V1
    class Comments < Grape::API
  
      before { detect_stuff_by_domain }
      before { authenticate! }
   
      resource :articles do
        # Collect comments from articles
        #
        # Parameters:
        #   reference_id     - comment id used as reference to collect comment
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /articles/12/comments?oldest&limit=10&reference_id=23
        get ":id/comments" do
          conditions = {}
          conditions = ["id #{params.key?(:oldest) ? '<' : '>'} ?", params[:reference_id]] if params[:reference_id]
          present environment.articles.find(params[:id]).comments.find(:all, :conditions => conditions, :limit => limit), :with => Entities::Comment
        end
   
        get ":id/comments/:comment_id" do
          present environment.articles.find(params[:id]).comments.find(params[:comment_id]), :with => Entities::Comment
        end
   
        # Example Request:
        #  POST api/v1/articles/12/comments?private_toke=234298743290432&body=new comment
        post ":id/comments" do
          present environment.articles.find(params[:id]).comments.create(:author => current_user, :body => params[:body]), :with => Entities::Comment
        end
      end
   
    end
  end
end
