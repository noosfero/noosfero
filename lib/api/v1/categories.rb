module API
  module V1
    class Categories < Grape::API
      before { detect_stuff_by_domain }
      before { authenticate! }
   
      resource :categories do

        get do
          type = params[:category_type]
          categories = type.nil? ?  environment.categories : environment.categories.find(:all, :conditions => {:type => type})
          present categories, :with => Entities::Category
        end
  
        desc "Return the category by id" 
        get ':id' do
          present environment.categories.find(params[:id]), :with => Entities::Category
        end

      end
   
    end
  end
end
