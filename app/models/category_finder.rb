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
      asset_class(asset).paginate(:all, options_for_find(asset_class(asset), {:order => "#{asset_table(asset)}.name"}.merge(options), date_range))
    else
      ferret_options = {:page => options.delete(:page), :per_page => options.delete(:per_page)}
      asset_class(asset).find_by_contents(query, ferret_options, options_for_find(asset_class(asset), options, date_range))
    end
  end

  def recent(asset, limit = nil)
    find(asset, nil, :limit => limit, :order => 'created_at DESC, id DESC')
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

  def product_categories_count(asset, product_categories_ids, objects_ids=nil)
    conditions = [ "product_categorizations.category_id in (?) and #{ProfileCategorization.table_name}.category_id = ?", product_categories_ids, category_id]

    if asset == :products
      if objects_ids
        conditions[0] += ' and product_categorizations.product_id in (?)'
        conditions << objects_ids
      end
      ProductCategory.find(
        :all, 
        :select => 'categories.id, count(*) as total', 
        :joins => "inner join product_categorizations on (product_categorizations.category_id = categories.id) inner join products on (products.id = product_categorizations.product_id) inner join #{ProfileCategorization.table_name} on (#{ProfileCategorization.table_name}.profile_id = products.enterprise_id)", 
        :group => 'categories.id', 
        :conditions => conditions
      )
    elsif asset == :enterprises
      if objects_ids
        conditions[0] += ' and products.enterprise_id in (?)'
        conditions << objects_ids
      end
      ProductCategory.find(
        :all,
        :select => 'categories.id, count(distinct products.enterprise_id) as total',
        :joins => "inner join product_categorizations on (product_categorizations.category_id = categories.id) inner join products on (products.id = product_categorizations.product_id) inner join #{ProfileCategorization.table_name} on (#{ProfileCategorization.table_name}.profile_id = products.enterprise_id)",
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

  def options_for_find(klass, options={}, date_range = nil)
    if defined? options[:product_category]
      prod_cat = options.delete(:product_category)
    end
    
    case klass.name
    when 'Comment'
      {:joins => 'inner join articles_categories on articles_categories.article_id = comments.article_id', :conditions => ['articles_categories.category_id = (?)', category_id]}.merge!(options)
    when 'Product'
      if prod_cat
        {:joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id inner join product_categorizations on (product_categorizations.product_id = products.id)', :conditions => ['categories_profiles.category_id = (?) and product_categorizations.category_id = (?)', category_id, prod_cat.id]}.merge!(options)
      else
        {:joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id = (?)', category_id]}.merge!(options)
      end
    when 'Article', 'TextArticle'
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
      if prod_cat
        {:joins => 'inner join categories_profiles on (categories_profiles.profile_id = profiles.id) inner join products on (products.enterprise_id = profiles.id) inner join product_categorizations on (product_categorizations.product_id = products.id)', :conditions => ['categories_profiles.category_id = (?) and product_categorizations.category_id = (?)', category_id, prod_cat.id]}.merge!(options)
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
