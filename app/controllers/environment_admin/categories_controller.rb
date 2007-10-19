class CategoriesController < EnvironmentAdminController

  protect [:index, :new, :edit, :remove], 'manage_environment_categories', environment
  
  helper :categories

  def index
    @categories = environment.top_level_categories
  end

  ALLOWED_TYPES = CategoriesHelper::TYPES.map {|item| item[1] }

  # posts back
  def new
    type = (params[:type] || 'Category')
    raise 'Type not allowed' unless ALLOWED_TYPES.include?(type)

    @category = type.constantize.new(params[:category])
    @category.environment = environment
    if params[:parent_id]
      @category.parent = environment.categories.find(params[:parent_id])
    end
    if request.post?
      begin
        @category.save!
        redirect_to :action => 'index'
      rescue Exception => e
        render :action => 'new'
      end
    end
  end

  # posts back
  def edit
    begin
      @category = environment.categories.find(params[:id])
      if request.post?
        @category.update_attributes!(params[:category])
        redirect_to :action => 'index'
      end
    rescue Exception => e
      render :action => 'edit'
    end
  end

  post_only :remove
  def remove
    environment.categories.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

end
