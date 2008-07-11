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

    date_range = options.delete(:date_range)

    options = {:page => 1, :per_page => options.delete(:limit)}.merge(options)
    if query.blank?
      options = {:order => "#{asset_table(asset)}.created_at desc, #{asset_table(asset)}.id desc"}.merge(options)
      if product_category && asset == :products
        @environment.send(asset).paginate(:all, options.merge(:include => 'product_categorizations', :conditions => ['product_categorizations.category_id = (?)', product_category.id]))
      elsif product_category && asset == :enterprises
        @environment.send(asset).paginate(:all, options.merge(:order => 'profiles.created_at desc, profiles.id desc', :include => 'products', :joins => 'inner join product_categorizations on (product_categorizations.product_id = products.id)', :conditions => ['product_categorizations.category_id = (?)', product_category.id]))
      else
        if (asset == :events) && date_range
          @environment.send(asset).paginate(:all, options.merge(:conditions => { :start_date => date_range}))
        else
          @environment.send(asset).paginate(:all, options)
        end
      end
    else
      ferret_options = {:page => options.delete(:page), :per_page => options.delete(:per_page)}
      if product_category && asset == :products
        # SECURITY no risk of SQL injection, since product_category_ids comes from trusted source
        @environment.send(asset).find_by_contents(query, ferret_options, options.merge({:include => 'product_categorizations', :conditions => 'product_categorizations.category_id = (%s)' % product_category.id }))
      elsif product_category && asset == :enterprises
        @environment.send(asset).find_by_contents(query, ferret_options, options.merge(:joins => 'inner join product_categorizations on (product_categorizations.product_id = products.id)', :include => 'products', :conditions => "product_categorizations.category_id = (#{product_category.id})"))
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

  protected

  def asset_class(asset)
    asset.to_s.singularize.camelize.constantize
  end
  
  def asset_table(asset)
    asset_class(asset).table_name
  end

end
