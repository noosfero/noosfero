module API
  module V1
    class Articles < Grape::API
      before { detect_stuff_by_domain }
      before { authenticate! }

      resource :articles do

        # Collect comments from articles
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /articles?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10&content_type=Hub
#    desc 'Articles.', {
#      :params => API::Entities::Article.documentation
#    }
        get do
          articles = select_filtered_collection_of(environment, 'articles', params)
          present articles, :with => Entities::Article 
        end

        desc "Return the article id"
        get ':id' do
          present environment.articles.find(params[:id]), :with => Entities::Article
        end

        get ':id/children' do

          conditions = make_conditions_with_parameter(params)
          if params[:reference_id]
            articles = environment.articles.find(params[:id]).children.send("#{params.key?(:oldest) ? 'older_than' : 'newer_than'}", params[:reference_id]).find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          else
            articles = environment.articles.find(params[:id]).children.find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          end
          present articles, :with => Entities::Article
        end

        get ':id/children/:child_id' do
          present environment.articles.find(params[:id]).children.find(params[:child_id]), :with => Entities::Article
        end


      end

      resource :communities do 
        segment '/:community_id' do 
          resource :articles do
            get do
              community = environment.communities.find(params[:community_id])
              articles = select_filtered_collection_of(community, 'articles', params)
              present articles, :with => Entities::Article 
            end

            get '/:id' do
              community = environment.communities.find(params[:community_id])
              present community.articles.find(params[:id]), :with => Entities::Article
            end

            # Example Request:
            #  POST api/v1/communites/:community_id/articles?private_toke=234298743290432&article[name]=title&article[body]=body
            post do
              community = environment.communities.find(params[:community_id])
              article = community.articles.build(params[:article].merge(:last_changed_by => current_person))
              article.type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
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
