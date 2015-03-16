module API
  module V1
    class Articles < Grape::API
      before { authenticate! }

      resource :articles do

        # Collect articles
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest articles. If nothing is passed the newest articles are collected
        #   limit            - amount of articles returned. The default value is 20
        #
        # Example Request:
        #  GET host/api/v1/articles?from=2013-04-04-14:41:43&until=2015-04-04-14:41:43&limit=10&private_token=e96fff37c2238fdab074d1dcea8e6317
        get do
          articles = select_filtered_collection_of(environment, 'articles', params)
          articles = articles.display_filter(current_user.person, nil)
          present articles, :with => Entities::Article
        end

        desc "Return the article id"
        get ':id' do
          article = find_article(environment.articles, params[:id])
          present article, :with => Entities::Article
        end

        get ':id/children' do
          article = find_article(environment.articles, params[:id])
          articles = select_filtered_collection_of(article, 'children', params)
          articles = articles.display_filter(current_user.person, nil)
          present articles, :with => Entities::Article
        end

        get ':id/children/:child_id' do
          article = find_article(environment.articles, params[:id])
          present find_article(article.children, params[:child_id]), :with => Entities::Article
        end

      end

      resource :communities do
        segment '/:community_id' do
          resource :articles do
            get do
              community = environment.communities.find(params[:community_id])
              articles = select_filtered_collection_of(community, 'articles', params)
              articles = articles.display_filter(current_user.person, community)
              present articles, :with => Entities::Article
            end

            get '/:id' do
              community = environment.communities.find(params[:community_id])
              article = find_article(community.articles, params[:id])
              present article, :with => Entities::Article
            end

            # Example Request:
            #  POST api/v1/communites/:community_id/articles?private_toke=234298743290432&article[name]=title&article[body]=body
            post do
              community = environment.communities.find(params[:community_id])
              return forbidden! unless current_user.person.can_post_content?(community)

              klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
              article = klass_type.constantize.new(params[:article])
              article.last_changed_by = current_person
              article.created_by= current_person
              article.profile = community

              if !article.save
                render_api_errors!(article.errors.full_messages)
              end
              present article, :with => Entities::Article
            end

          end
        end

      end

    end
  end
end
