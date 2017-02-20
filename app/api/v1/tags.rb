module Api
  module V1
    class Tags < Grape::API
      resource :articles do
        resource ':id/tags' do
          get do
            article = find_article(environment.articles, {:id => params[:id]})
            present_partial article.tag_list, {}
          end

          desc "Add a tag to an article"
          post do
            authenticate!
            article = find_article(environment.articles, {:id => params[:id]})
            article.tag_list=params[:tags]
            article.save
            present_partial article.tag_list, {}
          end
        end
      end

      resource :environment do
        desc 'Return the tag counts for this environment'
        get '/tags' do
          status Api::Status::DEPRECATED
          present_partial environment.tag_counts, {}
        end
      end

      resource :environments do
        resource ':id/tags' do
          get do
            local_environment = Environment.find(params[:id])
            present_partial local_environment.articles.tag_counts, {}
          end
        end

        desc 'Return the tag counts for this environment'
        get '/tags' do
          present_partial environment.articles.tag_counts, {}
        end
      end
    end
  end
end
