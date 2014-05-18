module API
  module V1
    class Communities < Grape::API
      before { detect_stuff_by_domain }
      before { authenticate! }
   
      resource :communities do

        # Collect comments from articles
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /communities?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10
        #  GET /communities?reference_id=10&limit=10&oldest
#    desc 'Articles.', {
#      :params => API::Entities::Article.documentation
#    }
        get do
          conditions = make_conditions_with_parameter(params)
                  
          if params[:reference_id]
            communities = environment.communities.send("#{params.key?(:oldest) ? 'older_than' : 'newer_than'}", params[:reference_id]).find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          else
            communities = environment.communities.find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          end
          present communities, :with => Entities::Community
        end
  
        desc "Return the article id" 
        get ':id' do
          present environment.communities.find(params[:id]), :with => Entities::Community
        end

      end
   
    end
  end
end
