module Noosfero
  module API
    module V1
      class Articles < Grape::API
        before { authenticate! }
  
        ARTICLE_TYPES = Article.descendants.map{|a| a.to_s}
  
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
            articles = articles.display_filter(current_person, nil)
            present articles, :with => Entities::Article, :fields => params[:fields]
          end
  
          desc "Return the article id"
          get ':id' do
            article = find_article(environment.articles, params[:id])
            present article, :with => Entities::Article, :fields => params[:fields]
          end
  
          get ':id/children' do
            article = find_article(environment.articles, params[:id])

            votes_order = params.delete(:order) if params[:order]=='votes_score'
            articles = select_filtered_collection_of(article, 'children', params)
            articles = articles.display_filter(current_person, nil)

            if votes_order
              articles = articles.joins(:votes).group('articles.id').reorder('sum(votes.id) DESC')
            end

            present articles, :with => Entities::Article, :fields => params[:fields]
          end
  
          get ':id/children/:child_id' do
            article = find_article(environment.articles, params[:id])
            present find_article(article.children, params[:child_id]), :with => Entities::Article, :fields => params[:fields]
          end

          # Example Request:
          #  POST api/v1/articles/:id/children?private_token=234298743290432&article[name]=title&article[body]=body
          post ':id/children' do

            parent_article = environment.articles.find(params[:id])
            return forbidden! unless current_person.can_post_content?(parent_article.profile)

            klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
            #FIXME see how to check the article types 
            #return forbidden! unless ARTICLE_TYPES.include?(klass_type)

            article = klass_type.constantize.new(params[:article])
            article.parent = parent_article
            article.last_changed_by = current_person
            article.created_by= current_person
            article.author= current_person
            article.profile = parent_article.profile

            if !article.save
              render_api_errors!(article.errors.full_messages)
            end
            present article, :with => Entities::Article, :fields => params[:fields]
          end

  
        end
  
        resource :communities do
          segment '/:community_id' do
            resource :articles do
              get do
                community = environment.communities.find(params[:community_id])
                articles = select_filtered_collection_of(community, 'articles', params)
                articles = articles.display_filter(current_person, community)
                present articles, :with => Entities::Article, :fields => params[:fields]
              end
  
              get ':id' do
                community = environment.communities.find(params[:community_id])
                article = find_article(community.articles, params[:id])
                present article, :with => Entities::Article, :fields => params[:fields]
              end
  
              # Example Request:
              #  POST api/v1/communites/:community_id/articles?private_token=234298743290432&article[name]=title&article[body]=body
              post do
                community = environment.communities.find(params[:community_id])
                return forbidden! unless current_person.can_post_content?(community)
  
                klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
                return forbidden! unless ARTICLE_TYPES.include?(klass_type)
  
                article = klass_type.constantize.new(params[:article])
                article.last_changed_by = current_person
                article.created_by= current_person
                article.profile = community
  
                if !article.save
                  render_api_errors!(article.errors.full_messages)
                end
                present article, :with => Entities::Article, :fields => params[:fields]
              end
  
            end
          end
  
        end
  
        resource :people do
          segment '/:person_id' do
            resource :articles do
              get do
                person = environment.people.find(params[:person_id])
                articles = select_filtered_collection_of(person, 'articles', params)
                articles = articles.display_filter(current_person, person)
                present articles, :with => Entities::Article, :fields => params[:fields]
              end
  
              get ':id' do
                person = environment.people.find(params[:person_id])
                article = find_article(person.articles, params[:id])
                present article, :with => Entities::Article, :fields => params[:fields]
              end
  
              post do
                person = environment.people.find(params[:person_id])
                return forbidden! unless current_person.can_post_content?(person)
  
                klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
                return forbidden! unless ARTICLE_TYPES.include?(klass_type)
  
                article = klass_type.constantize.new(params[:article])
                article.last_changed_by = current_person
                article.created_by= current_person
                article.profile = person
  
                if !article.save
                  render_api_errors!(article.errors.full_messages)
                end
                present article, :with => Entities::Article, :fields => params[:fields]
              end
  
            end
          end
  
        end
  
        resource :enterprises do
          segment '/:enterprise_id' do
            resource :articles do
              get do
                enterprise = environment.enterprises.find(params[:enterprise_id])
                articles = select_filtered_collection_of(enterprise, 'articles', params)
                articles = articles.display_filter(current_person, enterprise)
                present articles, :with => Entities::Article, :fields => params[:fields]
              end
  
              get ':id' do
                enterprise = environment.enterprises.find(params[:enterprise_id])
                article = find_article(enterprise.articles, params[:id])
                present article, :with => Entities::Article, :fields => params[:fields]
              end
  
              post do
                enterprise = environment.enterprises.find(params[:enterprise_id])
                return forbidden! unless current_person.can_post_content?(enterprise)
  
                klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
                return forbidden! unless ARTICLE_TYPES.include?(klass_type)
  
                article = klass_type.constantize.new(params[:article])
                article.last_changed_by = current_person
                article.created_by= current_person
                article.profile = enterprise
  
                if !article.save
                  render_api_errors!(article.errors.full_messages)
                end
                present article, :with => Entities::Article, :fields => params[:fields]
              end
  
            end
          end
  
        end
  
  
      end
    end
  end
end
