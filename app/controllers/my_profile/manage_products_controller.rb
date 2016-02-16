class ManageProductsController < ApplicationController
  needs_profile

  protect 'manage_products', :profile, :except => [:show]
  before_filter :check_environment_feature
  before_filter :login_required, :except => [:show]
  before_filter :create_product?, :only => [:new]

  protected

  def check_environment_feature
    unless profile.environment.enabled?('products_for_enterprises')
      render_not_found
      return
    end
  end

  def create_product?
    if !profile.create_product?
      render_access_denied
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
    @category = environment.categories.find_by_id params[:category_id]
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
    @no_design_blocks = true
    @category = params[:selected_category_id] ? Category.find(params[:selected_category_id]) : nil
    @product = @profile.products.build(:product_category => @category)
    @categories = ProductCategory.top_level_for(environment)
    @level = 0
    if request.post?
      if @product.save
        session[:notice] = _('Product succesfully created')
        render :partial => 'shared/redirect_via_javascript',
          :locals => { :url => url_for(:controller => 'manage_products', :action => 'show', :id => @product) }
      else
        render_dialog_error_messages 'product'
      end
    end
  end

  def edit
    @product = @profile.products.find(params[:id])
    field = params[:field]
    if request.post?
      begin
        @product.update!(params[:product])
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
    @category = @product.product_category || ProductCategory.first
    @categories = ProductCategory.top_level_for(environment)
    @edit = true
    @level = @category.level
    if request.post?
      if @product.update({:product_category_id => params[:selected_category_id]}, :without_protection => true)
        render :partial => 'shared/redirect_via_javascript',
          :locals => { :url => url_for(:controller => 'manage_products', :action => 'show', :id => @product) }
      else
        render_dialog_error_messages 'product'
      end
    end
  end

  def show_category_tree
    @category = environment.categories.find params[:category_id]
    render :partial => 'selected_category_tree'
  end

  def search_categories
    @term = params[:term].downcase
    conditions = ['LOWER(name) LIKE ? OR LOWER(name) LIKE ?', "#{@term}%", "% #{@term}%"]
    @categories = ProductCategory.all :conditions => conditions, :limit => 10
    render :json => (@categories.map do |category|
      {:label => category.name, :value => category.id}
    end)
  end

  def add_input
    @product = @profile.products.find(params[:id])
    @input = @product.inputs.build
    @categories = ProductCategory.top_level_for(environment)
    @level = 0
    if request.post?
      if @input.update(:product_category_id => params[:selected_category_id])
        @inputs = @product.inputs
        render :partial => 'display_inputs'
      else
        render_dialog_error_messages 'product'
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

  def display_price_composition_bar
    @product = @profile.products.find(params[:id])
    render :partial => 'price_composition_bar'
  end

  def display_inputs_cost
    @product = @profile.products.find(params[:id])
    render :inline => "<%= float_to_currency(@product.inputs_cost) %>"
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
          if @input.update(params[:input])
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
        render_dialog_error_messages 'input'
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
                       :error_msg => _(cost.errors['name'].join('\n')) % {:fn => _('Name')}
                      }.to_json
    end
  end
end
