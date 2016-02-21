require_dependency 'product'

class Product
  after_save_reindex [:enterprise], :with => :delayed_job

  acts_as_faceted :fields => {
      :solr_plugin_f_category => {:label => _('Related products')},
      :solr_plugin_f_region => {:label => c_('City'), :proc => proc { |id| solr_plugin_f_region_proc(id) }},
      :solr_plugin_f_qualifier => {:label => c_('Qualifiers'), :proc => proc { |id| solr_plugin_f_qualifier_proc(id) }},
    }, :category_query => proc { |c| "solr_plugin_category_filter:#{c.id}" },
    :order => [:solr_plugin_f_category, :solr_plugin_f_region, :solr_plugin_f_qualifier]

  SolrPlugin::Boosts = [
    [:image, 0.55, proc{ |p| p.image ? 1 : 0}],
    [:qualifiers, 0.45, proc{ |p| p.product_qualifiers.count > 0 ? 1 : 0}],
    [:open_price, 0.45, proc{ |p| p.price_described? ? 1 : 0}],
    [:solidarity, 0.45, proc{ |p| p.percentage_from_solidarity_economy[0].to_f/100 }],
    [:available, 0.35, proc{ |p| p.available ? 1 : 0}],
    [:price, 0.35, proc{ |p| (!p.price.nil? and p.price > 0) ? 1 : 0}],
    [:new_product, 0.35, proc{ |p| (p.updated_at.to_i - p.created_at.to_i) < 24*3600 ? 1 : 0}],
    [:description, 0.3, proc{ |p| !p.description.blank? ? 1 : 0}],
    [:enabled, 0.2, proc{ |p| p.enterprise.enabled ? 1 : 0}],
  ]

  acts_as_searchable :fields => facets_fields_for_solr + [
      # searched fields
      {:name => {:type => :text, :boost => 2.0}},
      {:description => :text}, {:category_full_name => :text},
      # filtered fields
      {:solr_plugin_public => :boolean},
      {:environment_id => :integer}, {:profile_id => :integer},
      {:enabled => :boolean}, {:solr_plugin_category_filter => :integer},
      # ordered/query-boosted fields
      {:solr_plugin_price_sortable => :decimal}, {:solr_plugin_name_sortable => :string},
      {:lat => :float}, {:lng => :float},
      :updated_at, :created_at,
    ], :include => [
      {:product_category => {:fields => [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
      {:region => {:fields => [:name, :path, :slug, :lat, :lng]}},
      {:enterprise => {:fields => [:name, :identifier, :address, :nickname, :lat, :lng]}},
      {:qualifiers => {:fields => [:name]}},
      {:certifiers => {:fields => [:name]}},
    ], :facets => facets_option_for_solr,
    :boost => proc{ |p| boost = 1; SolrPlugin::Boosts.each{ |b| boost = boost * (1 - ((1 - b[2].call(p)) * b[1])) }; boost}

  handle_asynchronously :solr_save
  handle_asynchronously :solr_destroy

  private

  def solr_plugin_f_category
    self.product_category.name
  end

  def solr_plugin_f_region
    self.enterprise.region.id if self.enterprise.region
  end

  def self.solr_plugin_f_region_proc(id)
    c = Region.find(id)
    s = c.parent
    if c and c.kind_of?(City) and s and s.kind_of?(State) and s.acronym
      [c.name, ', ' + s.acronym]
    else
      c.name
    end
  end

  def self.solr_plugin_f_qualifier_proc(ids)
    array = ids.split
    qualifier = Qualifier.find_by id: array[0]
    certifier = Certifier.find_by id: array[1]
    certifier ? [qualifier.name, _(' cert. ') + certifier.name] : qualifier.name
  end

  def solr_plugin_f_qualifier
    product_qualifiers.map do |pq|
      "#{pq.qualifier_id} #{pq.certifier_id}"
    end
  end

  def solr_plugin_category_filter
    enterprise.categories_including_virtual_ids << product_category_id
  end

  def solr_plugin_public
    self.public?
  end

  def solr_plugin_name_sortable # give a different name for solr
    name
  end

  def solr_plugin_price_sortable
    (price.nil? or price.zero?) ? nil : price
  end
end
