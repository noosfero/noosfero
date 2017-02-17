class CategoriesController < AdminController
  include CategoriesHelper

  protect 'manage_environment_categories', :environment

  helper :categories

  def get_children
    children = Category.find(params[:id]).children
    render :partial => 'category_children', :locals => {:children => children}
  end

  # posts back
  def new
    type = (params[:type] || params[:parent_type] || 'Category')
    raise 'Type not allowed' unless allowed_types.include?(type)

    @category = type.constantize.new(params[:category])
    @category.environment = environment
    if params[:parent_id]
      @category.parent = environment.categories.find(params[:parent_id])
    end
    if request.post?
      begin
        @category.save!
        @saved = true
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
        @category.update!(params[:category])
        @saved = true
        session[:notice] = _("Category %s saved." % @category.name).html_safe
        redirect_to :action => 'index'
      end
    rescue Exception => e
      session[:notice] = _('Could not save category.')
      render :action => 'edit'
    end
  end

  after_filter :manage_categories_menu_cache, :only => [:edit, :new]

  post_only :remove
  def remove
    environment.categories.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  protected

  def manage_categories_menu_cache
    if @saved && request.post? && @category.display_in_menu?
      expire_fragment(:controller => 'public', :action => 'categories_menu')
    end
  end

  def allowed_types
    category_types.map {|item| item[1] }
  end

end
