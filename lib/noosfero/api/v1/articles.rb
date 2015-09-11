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
            present_articles(environment)
          end

          desc "Return the article id"
          get ':id' do
            present_article(environment)
          end

          get ':id/children' do
            article = find_article(environment.articles, params[:id])

            #TODO make tests for this situation
            votes_order = params.delete(:order) if params[:order]=='votes_score'
            articles = select_filtered_collection_of(article, 'children', params)
            articles = articles.display_filter(current_person, nil)


            #TODO make tests for this situation
            if votes_order
              articles = articles.joins('left join votes on articles.id=votes.voteable_id').group('articles.id').reorder('sum(coalesce(votes.vote, 0)) DESC')
            end

            Article.hit(articles)
            present articles, :with => Entities::Article, :fields => params[:fields]
          end

          get ':id/children/:child_id' do
            article = find_article(environment.articles, params[:id])
            present find_article(article.children, params[:child_id]), :with => Entities::Article, :fields => params[:fields]
          end

          post ':id/children/suggest' do
            parent_article = environment.articles.find(params[:id])

            suggest_article = SuggestArticle.new
            suggest_article.article = params[:article]
            suggest_article.article[:parent_id] = parent_article.id
            suggest_article.target = parent_article.profile
            suggest_article.requestor = current_person

            unless suggest_article.save
              render_api_errors!(suggest_article.article_object.errors.full_messages)
            end
            present suggest_article, :with => Entities::Task, :fields => params[:fields]
          end

          # Example Request:
          #  POST api/v1/articles/:id/children?private_token=234298743290432&article[name]=title&article[body]=body
          post ':id/children' do

            parent_article = environment.articles.find(params[:id])
            return forbidden! unless parent_article.allow_create?(current_person)

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

        kinds = %w[community person enterprise]
        kinds.each do |kind|
          resource kind.pluralize.to_sym do
            segment "/:#{kind}_id" do
              resource :articles do
                get do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present_articles(profile)
                end

                get ':id' do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present_article(profile)
                end

                # Example Request:
                #  POST api/v1/{people,communities,enterprises}/:asset_id/articles?private_token=234298743290432&article[name]=title&article[body]=body
                post do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  post_article(profile, params)
                end
              end
            end
          end
        end
      end
    end
  end
end
