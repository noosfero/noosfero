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

          conditions = make_conditions_with_parameter(params)

          if params[:reference_id]
            articles = environment.articles.send("#{params.key?(:oldest) ? 'older_than' : 'newer_than'}", params[:reference_id]).find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          else
            articles = environment.articles.find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          end
          present articles, :with => Entities::Article
        end

        desc "Return the article id"
        get ':id' do
          present environment.articles.find(params[:id]), :with => Entities::Article
        end

        get ':id/children' do
          from_date = DateTime.parse(params[:from]) if params[:from]
          until_date = DateTime.parse(params[:until]) if params[:until]

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

    end
  end
end
