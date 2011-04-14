class EnvironmentFinder
  
  def initialize env
    @environment = env
  end

  def find(asset, query = nil, options={}, finder_method = 'paginate')
    @region = Region.find_by_id(options.delete(:region)) if options.has_key?(:region)
    if @region && options[:within]
      options[:origin] = [@region.lat, @region.lng]
    else
      options.delete(:within)
    end

    product_category = options.delete(:product_category)

    date_range = options.delete(:date_range)

    # FIXME this test is in more than one place
    if finder_method == 'paginate'
      options = {:page => 1, :per_page => options.delete(:limit)}.merge(options)
    end

    if query.blank?
      # FIXME this test is in more than one place
      if finder_method == 'paginate'
        options = {:order => "#{asset_table(asset)}.name"}.merge(options)
      end
      if product_category && asset == :products
        @environment.send(asset).send(finder_method, :all, options.merge(:include => 'product_categorizations', :conditions => ['product_categorizations.category_id = (?)', product_category.id]))
      elsif product_category && asset == :enterprises
        @environment.send(asset).send(finder_method, :all, options.merge( :order => 'profiles.name', :joins => 'inner join products on (products.enterprise_id = profiles.id) inner join product_categorizations on (product_categorizations.product_id = products.id)', :conditions => ['product_categorizations.category_id = (?)', product_category.id]))
      else
        if asset == :events
          # Ignore pagination for asset events
          options.delete(:per_page)
          options.delete(:page)
          if date_range
            @environment.send(asset).send('find', :all, options.merge(:conditions => [
              'start_date BETWEEN :start_day AND :end_day OR end_date BETWEEN :start_day AND :end_day',
                 {:start_day => date_range.first, :end_day => date_range.last}
            ]))
          else
            @environment.send(asset).send('find', :all, options)
          end
        else
          @environment.send(asset).send(finder_method, :all, options)
        end
      end
    else
      pg_options = {:page => options.delete(:page), :per_page => options.delete(:per_page)}
      if product_category && asset == :products
        # SECURITY no risk of SQL injection, since product_category_ids comes from trusted source
        @environment.send(asset).find_by_contents(query, pg_options, {}, options.merge({:include => 'product_categorizations', :conditions => 'product_categorizations.category_id = (%s)' % product_category.id }))[:results]
      elsif product_category && asset == :enterprises
        @environment.send(asset).find_by_contents(query, pg_options, {}, options.merge(:joins => 'inner join product_categorizations on (product_categorizations.product_id = products.id)', :include => 'products', :conditions => "product_categorizations.category_id = (#{product_category.id})"))[:results]
      else
        @environment.send(asset).find_by_contents(query, pg_options, {}, options)[:results]
      end
    end
  end

  def recent(asset, limit = nil)
    find(asset, nil, :limit => limit)
  end

  def product_categories_count(asset, product_categories_ids, objects_ids=nil)
    conditions = ['product_categorizations.category_id in (?)', product_categories_ids]

    if asset == :products
      if objects_ids
        conditions[0] += ' and product_categorizations.product_id in (?)'
        conditions << objects_ids
      end
      ProductCategory.find(:all, :select => 'categories.id, count(*) as total', :joins => 'inner join product_categorizations on (product_categorizations.category_id = categories.id)', :group => 'categories.id', :conditions => conditions )
    elsif asset == :enterprises
      if objects_ids
        conditions[0] += ' and products.enterprise_id in (?)'
        conditions << objects_ids
      end
      ProductCategory.find(
        :all,
        :select => 'categories.id, count(distinct products.enterprise_id) as total',
        :joins => 'inner join product_categorizations on (product_categorizations.category_id = categories.id) inner join products on (products.id = product_categorizations.product_id)',
        :group => 'categories.id', 
        :conditions => conditions 
      )
    else
      raise ArgumentError, 'only products and enterprises supported'
    end.inject({}) do |results,pc| 
        results[pc.id]= pc.total.to_i
        results
    end

  end

  protected

  def asset_class(asset)
    asset.to_s.singularize.camelize.constantize
  end
  
  def asset_table(asset)
    asset_class(asset).table_name
  end

end
