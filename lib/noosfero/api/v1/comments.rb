module Noosfero
  module API
    module V1
      class Comments < Grape::API
        MAX_PER_PAGE = 20

        before { authenticate! }

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
            article = find_article(environment.articles, params[:id])
            comments = select_filtered_collection_of(article, :comments, params)
            comments = comments.without_spam
            comments = comments.without_reply if(params[:without_reply].present?)
            comments = plugins.filter(:unavailable_comments, comments)
            present paginate(comments), :with => Entities::Comment, :current_person => current_person
          end

          get ":id/comments/:comment_id" do
            article = find_article(environment.articles, params[:id])
            present article.comments.find(params[:comment_id]), :with => Entities::Comment, :current_person => current_person
          end

          # Example Request:
          #  POST api/v1/articles/12/comments?private_token=2298743290432&body=new comment&title=New
          post ":id/comments" do
            article = find_article(environment.articles, params[:id])
            options = params.select { |key,v| !['id','private_token'].include?(key) }.merge(:author => current_person, :source => article)
            begin
              comment = Comment.create!(options)
            rescue ActiveRecord::RecordInvalid => e
              render_api_error!(e.message, 400)
            end
            present comment, :with => Entities::Comment, :current_person => current_person
          end
        end

      end
    end
  end
end
