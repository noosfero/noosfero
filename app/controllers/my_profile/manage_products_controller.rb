class ManageProductsController < ApplicationController
  needs_profile

  protect 'manage_products', :profile, :except => [:show]
  before_filter :check_environment_feature
  before_filter :login_required, :except => [:show]

  protected  

  def check_environment_feature
    if profile.environment.enabled?('disable_products_for_enterprises')
      render_not_found
      return
    end
  end

  public

  def index
    @products = @profile.products.paginate(:per_page => 10, :page => params[:page])
  end

  def show
    @product = @profile.products.find(params[:id])
    @inputs = @product.inputs
    @allowed_user = user && user.has_permission?('manage_products', profile)
  end

  def categories_for_selection
    @category = Category.find(params[:category_id]) if params[:category_id]
    @object_name = params[:object_name]
    if @category
      @categories = @category.children
      @level = @category.leaf? ? @category.level : @categories.first.level
    else
      @categories = ProductCategory.top_level_for(environment)
      @level = 0
    end
    render :partial => 'categories_for_selection', :locals => { :categories => @categories, :level => @level }
  end

  def new
    @product = @profile.products.build(:product_category_id => params[:selected_category_id])
    @category = @product.product_category
    @categories = ProductCategory.top_level_for(environment)
    @level = 0
    if request.post?
      if @product.save
        session[:notice] = _('Product succesfully created')
        render :partial => 'shared/redirect_via_javascript',
          :locals => { :url => url_for(:controller => 'manage_products', :action => 'show', :id => @product) }
      else
        render :partial => 'shared/dialog_error_messages', :locals => { :object_name => 'product' }
      end
    end
  end

  def edit
    @product = @profile.products.find(params[:id])
    field = params[:field]
    if request.post?
      begin
        @product.update_attributes!(params[:product])
        render :partial => "display_#{field}", :locals => {:product => @product}
      rescue Exception => e
        render :partial => "edit_#{field}", :locals => {:product => @product, :errors => true}
      end
    else
      render :partial => "edit_#{field}", :locals => {:product => @product, :errors => false}
    end
  end

  def edit_category
    @product = @profile.products.find(params[:id])
    @category = @product.product_category
    @categories = ProductCategory.top_level_for(environment)
    @edit = true
    @level = @category.level
    if request.post?
      if @product.update_attributes(:product_category_id => params[:selected_category_id])
        render :partial => 'shared/redirect_via_javascript',
          :locals => { :url => url_for(:controller => 'manage_products', :action => 'show', :id => @product) }
      else
        render :partial => 'shared/dialog_error_messages', :locals => { :object_name => 'product' }
      end
    end
  end

  def add_input
    @product = @profile.products.find(params[:id])
    @input = @product.inputs.build
    @categories = ProductCategory.top_level_for(environment)
    @level = 0
    if request.post?
      if @input.update_attributes(:product_category_id => params[:selected_category_id])
        @inputs = @product.inputs
        render :partial => 'display_inputs'
      else
        render :partial => 'shared/dialog_error_messages', :locals => { :object_name => 'product' }
      end
    else
      render :partial => 'add_input'
    end
  end

  def manage_product_details
    @product = @profile.products.find(params[:id])
    if request.post?
      @product.update_price_details(params[:price_details]) if params[:price_details]
      render :partial => 'display_price_details'
    else
      render :partial => 'manage_product_details'
    end
  end

  def remove_price_detail
    @product = @profile.products.find(params[:product])
    @price_detail = @product.price_details.find(params[:id])
    @product = @price_detail.product
    if request.post?
      @price_detail.destroy
      render :nothing => true
    end
  end

  def destroy
    @product = @profile.products.find(params[:id])
    if @product.destroy
      session[:notice] = _('Product succesfully removed')
      redirect_back_or_default :action => 'index'
    else
      session[:notice] = _('Could not remove the product')
      redirect_back_or_default :action => 'show', :id => @product
    end
  end

  def edit_input
    if request.xhr?
      @input = @profile.inputs.find_by_id(params[:id])
      if @input
        if request.post?
          if @input.update_attributes(params[:input])
            render :partial => 'display_input', :locals => {:input => @input}
          else
            render :partial => 'edit_input'
          end
        else
          render :partial => 'edit_input'
        end
      else
        render :text => _('The input was not found')
      end
    end
  end

  def order_inputs
    @product = @profile.products.find(params[:id])
    @product.order_inputs!(params[:input]) if params[:input]
    render :nothing => true
  end

  def remove_input
    @input = @profile.inputs.find(params[:id])
    @product = @input.product
    if request.post?
      if @input.destroy
        @inputs = @product.inputs
        render :partial => 'display_inputs'
      else
        render :partial => 'shared/dialog_error_messages', :locals => { :object_name => 'input' }
      end
    end
  end

  def certifiers_for_selection
    @qualifier = Qualifier.exists?(params[:id]) ? Qualifier.find(params[:id]) : nil
    render :update do |page|
      page.replace_html params[:certifier_area], :partial => 'certifiers_for_selection'
    end
  end

  def create_production_cost
    cost = @profile.production_costs.create(:name => params[:id])
    if cost.valid?
      cost.save
      render :text => {:name => cost.name,
                       :id => cost.id,
                       :ok => true
                      }.to_json
    else
      render :text => {:ok => false,
                       :error_msg => _(cost.errors['name']) % {:fn => _('Name')}
                      }.to_json
    end
  end
end
