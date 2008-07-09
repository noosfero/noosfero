class CategoryFinder

  def initialize(cat)
    @category = cat
    @category_id = @category.id
  end

  attr_reader :category_id

  def find(asset, query='', options={})
   @region = Region.find_by_id(options.delete(:region)) if options.has_key?(:region)
    if @region && options[:within]
      options[:origin] = [@region.lat, @region.lng]
    else
      options.delete(:within)
    end

    date_range = options.delete(:date_range)

    options = {:page => 1, :per_page => options.delete(:limit)}.merge(options)
    if query.blank?
      asset_class(asset).paginate(:all, options_for_find(asset_class(asset), {:order => "created_at desc, #{asset_table(asset)}.id desc"}.merge(options), date_range))
    else
      ferret_options = {:page => options.delete(:page), :per_page => options.delete(:per_page)}
      asset_class(asset).find_by_contents(query, ferret_options, options_for_find(asset_class(asset), options, date_range))
    end
  end

  def recent(asset, limit = nil)
    find(asset, nil, :limit => limit)
  end

  def count(asset, query='', options={})
    # because will_paginate needs a page
    options = {:page => 1}.merge(options)
    find(asset, query, options).total_entries
  end

  def most_commented_articles(limit=10, options={})
    options = {:page => 1, :per_page => limit, :order => 'comments_count DESC'}.merge(options)
    Article.paginate(:all, options_for_find(Article, options))
  end

  def current_events(year, month, options={})
    options = {:page => 1}.merge(options)
    range = Event.date_range(year, month)

    Event.paginate(:all, {:include => :categories, :conditions => { 'categories.id' => category_id, :start_date => range }}.merge(options))
  end

  def upcoming_events(options = {})
    options = { :page => 1}.merge(options)

    Event.paginate(:all, {:include => :categories, :conditions => [ 'categories.id = ? and start_date >= ?', category_id, Date.today ], :order => 'start_date' }.merge(options))
  end

  protected

  def options_for_find(klass, options={}, date_range = nil)
    if defined? options[:product_category]
      prod_cat = options.delete(:product_category)
      # FIXME this is SLOOOOW
      prod_cat_ids = prod_cat.map_traversal(&:id) if prod_cat
    end
    
    case klass.name
    when 'Comment'
      {:joins => 'inner join articles_categories on articles_categories.article_id = comments.article_id', :conditions => ['articles_categories.category_id = (?)', category_id]}.merge!(options)
    when 'Product'
      if prod_cat_ids
        {:joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id = (?) and products.product_category_id in (?)', category_id, prod_cat_ids]}.merge!(options)
      else
        {:joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id = (?)', category_id]}.merge!(options)
      end
    when 'Article'
      {:joins => 'inner join articles_categories on (articles_categories.article_id = articles.id)', :conditions => ['articles_categories.category_id = (?)', category_id]}.merge!(options)
    when 'Event'
      conditions =
        if date_range
          ['articles_categories.category_id = (?) and start_date between ? and ?', category_id, date_range.first, date_range.last]
        else
          ['articles_categories.category_id = (?) ', category_id ]
        end
      {:joins => 'inner join articles_categories on (articles_categories.article_id = articles.id)', :conditions => conditions}.merge!(options)
    when 'Enterprise'
      if prod_cat_ids
        {:joins => 'inner join categories_profiles on (categories_profiles.profile_id = profiles.id) inner join products on (products.enterprise_id = profiles.id)', :conditions => ['categories_profiles.category_id = (?) and products.product_category_id in (?)', category_id, prod_cat_ids]}.merge!(options)
      else
        {:joins => 'inner join categories_profiles on (categories_profiles.profile_id = profiles.id)', :conditions => ['categories_profiles.category_id = (?)', category_id]}.merge!(options)
      end    
    when 'Person', 'Community'
      {:joins => 'inner join categories_profiles on (categories_profiles.profile_id = profiles.id)', :conditions => ['categories_profiles.category_id = (?)', category_id]}.merge!(options)
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
