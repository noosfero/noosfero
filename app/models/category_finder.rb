class CategoryFinder

  def initialize(cat)
    @category = cat
    @category_ids = @category.map_traversal(&:id)
  end

  attr_reader :category_ids

  

  def find(asset, query = nil, options={}, limit = nil)
   @region = Region.find_by_id(options.delete(:region)) if options.has_key?(:region)
    if @region && options[:within]
      options[:origin] = [@region.lat, @region.lng]
    else
      options.delete(:within)
    end

    if query.blank?
      asset_class(asset).find(:all, options_for_find(asset_class(asset), {:limit => limit, :order => "created_at desc, #{asset_table(asset)}.id desc"}.merge(options)))
    else 
      asset_class(asset).find_by_contents(query, {}, options_for_find(asset_class(asset), options)).uniq
    end
  end

  def recent(asset, limit = nil)
    find(asset, nil, {}, limit)
  end

  def find_by_initial(asset, initial)
    asset_class(asset).find(:all, options_for_find_by_initial(asset_class(asset), initial))
  end

  def count(asset)
    asset_class(asset).count(:all, options_for_find(asset_class(asset), :select => "#{asset_table(asset)}.id"))
  end

  def most_commented_articles(limit=10)
    Article.find(:all, options_for_find(Article, :limit => limit, :order => 'comments_count DESC'))
  end

  def current_events(year, month)
    range = Event.date_range(year, month)

    Event.find(:all, :include => :categories, :conditions => { 'categories.id' => category_ids, :start_date => range })
  end

  protected

  def options_for_find(klass, options={})
    if defined? options[:product_category]
      prod_cat = options.delete(:product_category)
      prod_cat_ids = prod_cat.map_traversal(&:id) if prod_cat
    end
    
    case klass.name
    when 'Comment'
      {:select => 'distinct comments.*', :joins => 'inner join articles_categories on articles_categories.article_id = comments.article_id', :conditions => ['articles_categories.category_id in (?)', category_ids]}.merge!(options)
    when 'Product'
      if prod_cat_ids
        {:select => 'distinct products.*', :joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id in (?) and products.product_category_id in (?)', category_ids, prod_cat_ids]}.merge!(options)
      else
        {:select => 'distinct products.*', :joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id in (?)', category_ids]}.merge!(options)
      end
    when 'Article', 'Person', 'Community', 'Enterprise', 'Event'
      {:include => 'categories', :conditions => ['categories.id IN (?)', category_ids]}.merge!(options)
    else
      raise "unreconized class #{klass.name}"
    end
  end

  def options_for_find_by_initial(klass, initial)
    # FIXME copy/pasted from options_for_find above !!!
    case klass.name
    when 'Product'
      {:select => 'distinct products.*', :joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id in (?) and (products.name like (?) or products.name like (?))', category_ids, initial + '%', initial.upcase + '%']}
    when 'Article', 'Person', 'Community', 'Enterprise'
      {:include => 'categories', :conditions => ['categories.id IN (?) and (%s.name like (?) or %s.name like (?))' % [klass.table_name, klass.table_name], category_ids, initial + '%', initial.upcase + '%']}
    else
      raise "unreconized class #{klass.name}"
    end
  end

  def asset_class(asset)
    asset.to_s.singularize.camelize.constantize
  end
  
  def asset_table(asset)
    asset_class(asset).table_name
  end
end
