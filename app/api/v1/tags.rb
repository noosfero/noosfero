module Api
  module V1
    class Tags < Grape::API
      resource :articles do
        resource ':id/tags' do
          get do
            article = find_article(environment.articles, params[:id])
            present article.tag_list
          end

          desc "Add a tag to an article"
          post do
            authenticate!
            article = find_article(environment.articles, params[:id])
            article.tag_list=params[:tags]
            article.save
            present article.tag_list
          end
        end
      end

      resource :environment do
        desc 'Return the tag counts for this environment'
        get '/tags' do
          present environment.tag_counts
        end
      end
    end
  end
end
