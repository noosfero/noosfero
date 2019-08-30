module Api
  module V1
    class Categories < Grape::API::Instance
      resource :categories do
        get do
          type = params[:category_type]
          include_parent = params[:include_parent] == "true"
          include_children = params[:include_children] == "true"

          categories = type.nil? ? environment.categories : environment.categories.where(type: type)
          present_partial categories, with: Entities::Category, parent: include_parent, children: include_children
        end

        desc "Return the category by id"
        get ":id" do
          present_partial environment.categories.find(params[:id]), with: Entities::Category, parent: true, children: true
        end
      end
    end
  end
end
