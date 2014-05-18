module API
  module V1
    class People < Grape::API
      before { detect_stuff_by_domain }
      before { authenticate! }
   
      resource :people do

        # Collect comments from articles
        #
        # Parameters:
        #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
        #   oldest           - Collect the oldest comments from reference_id comment. If nothing is passed the newest comments are collected
        #   limit            - amount of comments returned. The default value is 20
        #
        # Example Request:
        #  GET /people?from=2013-04-04-14:41:43&until=2014-04-04-14:41:43&limit=10
        #  GET /people?reference_id=10&limit=10&oldest
#    desc 'Articles.', {
#      :params => API::Entities::Article.documentation
#    }
        get do
          conditions = make_conditions_with_parameter(params)
                  
          if params[:reference_id]
            people = environment.people.send("#{params.key?(:oldest) ? 'older_than' : 'newer_than'}", params[:reference_id]).find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          else
            people = environment.people.find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
          end
          present people, :with => Entities::Person
        end
    

        segment '/:person_id' do  
 
          desc "Return the person information" 
          get do
            present environment.people.find(params[:person_id]), :with => Entities::Person
          end
  
          resource '/communities' do 
            desc "Return all communities of person" 
            get  do
              person = environment.people.find(params[:person_id])
              conditions = make_conditions_with_parameter(params)
                      
              if params[:reference_id]
                communities = person.communities.send("#{params.key?(:oldest) ? 'older_than' : 'newer_than'}", params[:reference_id]).find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
              else
                communities = person.communities.find(:all, :conditions => conditions, :limit => limit, :order => "created_at DESC")
              end
              present communities, :with => Entities::Community
            end

            desc "Return all communities of person" 
            get '/:id' do
              person = environment.people.find(params[:person_id])
              present person.communities.find(params[:id]), :with => Entities::Community
            end
          end
        end

      end
   
    end
  end
end
