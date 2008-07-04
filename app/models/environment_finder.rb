class EnvironmentFinder
  
  def initialize env
    @environment = env
  end

  def find(asset, query = nil, options={})
    @region = Region.find_by_id(options.delete(:region)) if options.has_key?(:region)
    if @region && options[:within]
      options[:origin] = [@region.lat, @region.lng]
    else
      options.delete(:within)
    end

    product_category = options.delete(:product_category)
    product_category_ids = product_category.map_traversal(&:id) if product_category

    options = {:page => 1, :per_page => options.delete(:limit)}.merge(options)
    if query.blank?
      options = {:order => 'created_at desc, id desc'}.merge(options)
      if product_category && asset == :products
        @environment.send(asset).paginate(:all, options.merge(:conditions => ['product_category_id in (?)', product_category_ids]))
      elsif product_category && asset == :enterprises
        @environment.send(asset).paginate(:all, options.merge(:order => 'profiles.created_at desc, profiles.id desc', :include => 'products', :conditions => ['products.product_category_id in (?)', product_category_ids]))
      else
        @environment.send(asset).paginate(:all, options)
      end
    else
      ferret_options = {:page => options.delete(:page), :per_page => options.delete(:per_page)}
      if product_category && asset == :products
        # SECURITY no risk of SQL injection, since product_category_ids comes from trusted source
        @environment.send(asset).find_by_contents(query, ferret_options, options.merge({:conditions => 'product_category_id in (%s)' % product_category_ids.join(',') }))
      elsif product_category && asset == :enterprises
        @environment.send(asset).find_by_contents(query, ferret_options, options.merge(:include => 'products', :conditions => "products.product_category_id in (#{product_category_ids})"))
      else
        @environment.send(asset).find_by_contents(query, ferret_options, options)
      end
    end
  end

  def recent(asset, limit = nil)
    find(asset, nil, :limit => limit)
  end

  def count(asset, query = '', options = {})
    # because will_paginate needs a page
    options = {:page => 1}.merge(options)
    find(asset, query, options).total_entries
  end

end
