module Api
  module V1
    class Tags < Grape::API
      resource :articles do
        resource ':id/tags' do
          get do
            article = find_article(environment.articles, {:id => params[:id]})
            present_tags_for_asset(article)
          end

          desc "Add a tag to an article"
          post do
            authenticate!
            article = find_article(environment.articles, {:id => params[:id]})
            article.tag_list=params[:tags]
            article.save
            present_tags_for_asset(article)
          end
        end
      end

      resource :profiles do
        resource ':id/tags' do
          get do
            profile = environment.profiles.find params[:id]
            present_tags_for_asset(profile)
          end

          desc "Add a tag to a profile"
          post do
            authenticate!
            profile = environment.profiles.find params[:id]
            profile.tag_list=params[:tags]
            profile.save
            present_tags_for_asset(profile)
          end
        end
      end

      resource :environments do
        resource ':id/tags' do
          get do
            local_environment = Environment.find(params[:id])
            present_tags_for_asset(local_environment)
          end
        end

        desc 'Return the tag counts for this environment'
        get '/tags' do
          present_tags_for_asset(environment)
        end
      end
    end
  end
end
