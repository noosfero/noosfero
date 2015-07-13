module SnifferPlugin::Helper

  include Noosfero::GeoRef

  def distance_between_profiles(source, target)
    Math.sqrt(
      (KM_LAT * ((target.lat || 0) - (source.lat || 0)))**2 +
      (KM_LNG * ((target.lng || 0) - (source.lng || 0)))**2
    )
  end

  def filter_visible_attr_profile(profile)
    filtered_profile = {}
    visible_attributes = [:id, :name, :lat, :lng, :sniffer_plugin_distance]
    visible_attributes.each{ |a| filtered_profile[a] = profile[a] || 0 }
    filtered_profile
  end

  def filter_visible_attr_suppliers_products(products)
    visible_attributes = [:id, :profile_id, :product_category_id, :view, :knowledge_id, :supplier_profile_id]
    products.map do |product|
      filtered_supplier = {}
      visible_attributes.each{ |a| filtered_supplier[a] = product[a] }
      filtered_supplier
    end
  end

  def filter_visible_attr_consumers_products(products)
    visible_attributes = [:id, :profile_id, :product_category_id, :view, :knowledge_id, :consumer_profile_id]
    products.map do |product|
      filtered_consumer = {}
      visible_attributes.each{ |a| filtered_consumer[a] = product[a] }
      filtered_consumer
    end
  end

end
