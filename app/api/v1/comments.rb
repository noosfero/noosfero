module Api
  module V1
    class Comments < Grape::API
      MAX_PER_PAGE = 20


      resource :articles do
        paginate max_per_page: MAX_PER_PAGE
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
          article = find_article(environment.articles, {:id => params[:id]})
          comments = select_filtered_collection_of(article, :comments, params)
          comments = comments.without_spam
          comments = comments.without_reply if(params[:without_reply].present?)
          comments = plugins.filter(:unavailable_comments, comments)
          present_partial paginate(comments), :with => Entities::Comment, :current_person => current_person
        end

        get ":id/comments/:comment_id" do
          article = find_article(environment.articles, {:id => params[:id]})
          present_partial article.comments.find(params[:comment_id]), :with => Entities::Comment, :current_person => current_person
        end

        # Example Request:
        #  POST api/v1/articles/12/comments?private_token=2298743290432&body=new comment&title=New
        post ":id/comments" do
          authenticate!
          article = find_article(environment.articles, {:id => params[:id]})
          return forbidden! unless article.accept_comments?
          options = params.select { |key,v| !['id','private_token'].include?(key) }.merge(:author => current_person, :source => article)
          begin
            comment = Comment.create!(options)
          rescue ActiveRecord::RecordInvalid => e
            render_api_error!(e.message, Api::Status::Http::BAD_REQUEST)
          end
          present_partial comment, :with => Entities::Comment, :current_person => current_person
        end

        delete ":id/comments/:comment_id" do
          article = find_article(environment.articles, {:id => params[:id]})
          comment = article.comments.find_by_id(params[:comment_id])
          return not_found! if comment.nil?
          return forbidden! unless comment.can_be_destroyed_by?(current_person)
          begin
            comment.destroy
            present_partial comment, with: Entities::Comment, :current_person => current_person
          rescue => e
            render_api_error!(e.message, 500)
          end
        end
      end

    end
  end
end
