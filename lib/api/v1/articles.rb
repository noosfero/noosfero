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
          from_date = DateTime.parse(params[:from]) if params[:from]
          until_date = DateTime.parse(params[:until]) if params[:until]
  
          if from_date.nil?
            begin_period = Time.at(0).to_datetime
            end_period = until_date.nil? ? DateTime.now : until_date
          else
            begin_period = from_date
            end_period = DateTime.now
          end
  
          conditions = {}
          conditions[:type] = params[:content_type] if params[:content_type] #FIXME validate type
          conditions[:created_at] = begin_period...end_period
          present environment.articles.find(:all, :conditions => conditions, :offset => (from_date.nil? ? 0 : 1), :limit => limit, :order => "created_at DESC"), :with => Entities::Article 
        end
  
        desc "Return the article id" 
        get ':id' do
          present environment.articles.find(params[:id]), , :with => Entities::Article
        end

        get ':id/children' do
          present environment.articles.find(params[:id]).children.find(:all, :limit => limit), , :with => Entities::Article
        end

        get ':id/children/:child_id' do
          present environment.articles.find(params[:id]).children.find(params[:child_id]), :with => Entities::Article
        end


      end
   
    end
  end
end
