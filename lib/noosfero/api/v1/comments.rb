module Noosfero
  module API
    module V1
      class Comments < Grape::API
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
  
            conditions = make_conditions_with_parameter(params)
            article = find_article(environment.articles, params[:id])
  
            if params[:reference_id]
              created_at = article.comments.find(params[:reference_id]).created_at
              comments = article.comments.send("#{params.key?(:oldest) ? 'older_than' : 'younger_than'}", created_at).reorder("created_at DESC").find(:all, :conditions => conditions, :limit => limit)
            else
              comments = article.comments.reorder("created_at DESC").find(:all, :conditions => conditions, :limit => limit)
            end
            present comments, :with => Entities::Comment
  
          end
  
          get ":id/comments/:comment_id" do
            article = find_article(environment.articles, params[:id])
            present article.comments.find(params[:comment_id]), :with => Entities::Comment
          end
  
          # Example Request:
          #  POST api/v1/articles/12/comments?private_toke=234298743290432&body=new comment
          post ":id/comments" do
            article = find_article(environment.articles, params[:id])
            present article.comments.create(:author => current_person, :body => params[:body]), :with => Entities::Comment
          end
        end
  
      end
    end
  end
end
