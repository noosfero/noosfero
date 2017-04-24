module Api
  module V1
    class Tags < Grape::API
      resource :articles do
        resource ':id/tags' do
          get do
            article = find_article(environment.articles, {:id => params[:id]})
            present_partial article.tags, :with => Entities::Tag
          end

          desc "Add a tag to an article"
          post do
            authenticate!
            article = find_article(environment.articles, {:id => params[:id]})
            article.tag_list=params[:tags]
            article.save
            present_partial article.tags, :with => Entities::Tag
          end
        end
      end

      resource :profiles do
        resource ':id/tags' do
          get do
            profile = environment.profiles.find params[:id]
            present_partial profile.tags, :with => Entities::Tag
          end

          desc "Add a tag to a profile"
          post do
            authenticate!
            profile = environment.profiles.find params[:id]
            profile.tag_list=params[:tags]
            profile.save
            present_partial profile.tags, :with => Entities::Tag
          end
        end
      end

      resource :environments do
        resource ':id/tags' do
          get do
            local_environment = Environment.find(params[:id])
            present_partial local_environment.tags, :with => Entities::Tag
          end
        end

        desc 'Return the tag counts for this environment'
        get '/tags' do
          present_partial environment.tags, :with => Entities::Tag
        end
      end
    end
  end
end
