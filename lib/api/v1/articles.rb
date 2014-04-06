module API
  module V1
  class Articles < Grape::API
 
    resource :articles do

      get do
        first_update = DateTime.parse(params[:first_update]) if params[:first_update]
        last_update = DateTime.parse(params[:last_update]) if params[:last_update]

        if first_update.nil?
          begin_date = Article.first.created_at
          end_date = last_update.nil? ? DateTime.now : last_update
        else
          begin_date = first_update
          end_date = DateTime.now
        end

        limit = params[:limit].to_i
        limit = 20 if limit == 0
        conditions = {}
        conditions[:type] = params[:content_type] if params[:content_type] #FIXME validate type
        conditions[:created_at] = begin_date...end_date
        Article.find(:all, :conditions => conditions, :offset => (first_update.nil? ? 0 : 1), :limit => limit, :order => "created_at DESC")
      end
 
      get ':id' do
        Article.find(params[:id])
      end
    end
 
  end
  end
end
