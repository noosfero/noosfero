class SnifferPluginMyprofileController < MyProfileController

  before_filter :fetch_sniffer_profile, :only => [:edit, :search]

  include SnifferPlugin::Helper
  helper SnifferPlugin::Helper
  helper CmsHelper

  def edit
    if request.post?
      begin
        @sniffer_profile.update_attributes(params[:sniffer_plugin_profile])
        @sniffer_profile.enabled = true
        @sniffer_profile.save!
        session[:notice] = _('Consumer interests updated')
      rescue Exception => exception
        flash[:error] = _('Could not save consumer interests')
      end
    end
  end

  def product_category_search
    query = params[:q] || params[:term]

    scope = ProductCategory.by_environment(environment)
    @categories = find_by_contents(:product_categories, @profile, scope, query, {:per_page => 10, :page => 1})[:results]

    autocomplete = params.has_key?(:term)
    render :json => @categories.map { |i| autocomplete ? {:value => i.id, :label => i.name} : {:id => i.id, :name => i.name} }
  end

  def product_category_add
    product_category = environment.categories.find params[:id]
    response = { :productCategory => {
        :id   => product_category.id
      }
    }
    response[:enterprises] = product_category.sniffer_plugin_enterprises.enabled.visible.map do |enterprise|
      profile_data = filter_visible_attr_profile(enterprise)
      profile_data[:balloonUrl] = url_for :controller => :sniffer_plugin_myprofile, :action => :map_balloon, :id => enterprise[:id], :escape => false
      profile_data[:sniffer_plugin_distance] = distance_between_profiles(@profile, enterprise)
      profile_data[:suppliersProducts] = filter_visible_attr_suppliers_products(
        enterprise.products.sniffer_plugin_products_from_category(product_category)
      )
      profile_data[:consumersProducts] = []
      profile_data
    end
    render :text => response.to_json
  end

  def search
    @no_design_blocks = true

    suppliers_products = @sniffer_profile.suppliers_products
    consumers_products = @sniffer_profile.consumers_products

    profiles_of_interest = fetch_profiles(suppliers_products + consumers_products)

    suppliers_categories = suppliers_products.collect(&:product_category)
    consumers_categories = consumers_products.collect(&:product_category)

    @categories = categories_with_interest_type(suppliers_categories, consumers_categories)

    suppliers = suppliers_products.group_by{ |p| target_profile_id(p) }
    consumers = consumers_products.group_by{ |p| target_profile_id(p) }

    @profiles_data = {}
    suppliers.each do |id, products|
      @profiles_data[id] = {
        :profile => profiles_of_interest[id],
        :suppliers_products => products,
        :consumers_products => []
      }
    end
    consumers.each do |id, products|
      @profiles_data[id] ||= { :profile => profiles_of_interest[id] }
      @profiles_data[id][:suppliers_products] ||= []
      @profiles_data[id][:consumers_products] = products
    end
  end

  def map_balloon
    @profile_of_interest = Profile.find params[:id]
    @categories = @profile_of_interest.categories

    suppliers_products = params[:suppliersProducts].blank? ? [] : params[:suppliersProducts].values
    consumers_products = params[:consumersProducts].blank? ? [] : params[:consumersProducts].values
    @empty = suppliers_products.empty? && consumers_products.empty?
    @has_both = !suppliers_products.blank? && !consumers_products.blank?

    @suppliers = build_products(suppliers_products).values.first
    @consumers = build_products(consumers_products).values.first

    render :layout => false
  end

  def my_map_balloon
    @categories = @profile.categories
    render :layout => false
  end

  protected

  def fetch_sniffer_profile
    @sniffer_profile = SnifferPlugin::Profile.find_or_create profile
  end

  def fetch_profiles(products)
    profiles = Profile.all :conditions => {:id => products.map { |p| target_profile_id(p) }}
    profiles_by_id = {}
    profiles.each do |p|
      p[:sniffer_plugin_distance] = distance_between_profiles(@profile, p)
      profiles_by_id[p.id] ||= p
    end
    profiles_by_id
  end

  def build_products(data)
    id_products, id_knowledges = {}, {}

    results = {}
    return results if data.blank?

    grab_id = proc{ |field| data.map{ |h| h[field].to_i }.uniq }

    id_profiles = fetch_profiles(data)

    products = Product.all :conditions => {:id => grab_id.call('id')}, :include => [:enterprise, :product_category]
    products.each{ |p| id_products[p.id] ||= p }
    knowledges = Article.all :conditions => {:id => grab_id.call('knowledge_id')}
    knowledges.each{ |k| id_knowledges[k.id] ||= k}

    data.each do |attributes|
      profile = id_profiles[target_profile_id(attributes)]

      results[profile.id] ||= []
      results[profile.id] << {
        :partial => attributes['view'],
        :product => id_products[attributes['id'].to_i],
        :knowledge => id_knowledges[attributes['knowledge_id'].to_i]
      }
    end
    results
  end

  def target_profile_id(product)
    p = product.is_a?(Hash) ? product : product.attributes
    p.delete_if { |key, value| value.blank? }
    (p['consumer_profile_id'] || p['supplier_profile_id'] || p['profile_id']).to_i
  end

  def categories_with_interest_type(suppliers_categories, consumers_categories)
    (suppliers_categories + consumers_categories).sort_by(&:name).uniq.map do |category|
      c = {id: category.id, name: category.name}
      if suppliers_categories.include?(category) && consumers_categories.include?(category)
        c[:interest_type] = :both
      else
        suppliers_categories.include?(category) ? c[:interest_type] = :supplier : c[:interest_type] = :consumer
      end
      c
    end
  end

end
