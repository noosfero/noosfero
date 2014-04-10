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
          from_date = DateTime.parse(params[:from]) if params[:from]
          until_date = DateTime.parse(params[:until]) if params[:until]

          conditions = {}
          conditions[:created_at] = period(from_date, until_date)
          if params[:reference_id]
            comments = environment.articles.find(params[:id]).comments.send("#{params.key?(:oldest) ? 'older_than' : 'newer_than'}", params[:reference_id]).find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          else
            comments = environment.articles.find(params[:id]).comments.find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          end
          present comments, :with => Entities::Comment

        end
   
        get ":id/comments/:comment_id" do
          present environment.articles.find(params[:id]).comments.find(params[:comment_id]), :with => Entities::Comment
        end
   
        # Example Request:
        #  POST api/v1/articles/12/comments?private_toke=234298743290432&body=new comment
        post ":id/comments" do
          present environment.articles.find(params[:id]).comments.create(:author => current_person, :body => params[:body]), :with => Entities::Comment
        end
      end
   
    end
  end
end
