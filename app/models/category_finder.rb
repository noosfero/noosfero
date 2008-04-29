class CategoryFinder

  def initialize(cat)
    @category = cat
    @category_ids = @category.map_traversal(&:id)
  end

  attr_reader :category_ids

  def articles(query='*', options={})
    find_in_categorized(Article, query, options)
  end

  def people(query='*', options={})
    find_in_categorized(Person, query, options)
  end

  def communities(query='*', options={})
    find_in_categorized(Community, query, options)
  end

  def enterprises(query='*', options={})
    find_in_categorized(Enterprise, query, options)
  end

  def products(query='*', options={})
    find_in_categorized(Product, query, options)
  end

  def comments(query='*', options={})
    find_in_categorized(Comment, query, options)
  end

  def recent(asset, limit = 10)
    asset_class(asset).find(:all, options_for_find(asset_class(asset), {:limit => limit, :order => "created_at desc, #{asset_table(asset)}.id desc"}))
  end

  def find_by_initial(asset, initial)
    asset_class(asset).find(:all, options_for_find_by_initial(asset_class(asset), initial))
  end

  def count(asset)
    asset_class(asset).count(:all, options_for_find(asset_class(asset)))
  end

  def most_commented_articles(limit=10)
    Article.find(:all, options_for_find(Article, :limit => limit, :order => 'comments_count DESC'))
  end

  protected

  def find_in_categorized(klass, query, options={})
    klass.find_by_contents(query, {}, options_for_find(klass, options)).uniq
  end

  def options_for_find(klass, options={})
    case klass.name
    when 'Comment'
      {:select => 'distinct comments.*', :joins => 'inner join articles_categories on articles_categories.article_id = comments.article_id', :conditions => ['articles_categories.category_id in (?)', category_ids]}.merge!(options)
    when 'Product'
      {:select => 'distinct products.*', :joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id in (?)', category_ids]}.merge!(options)
    when 'Article', 'Person', 'Community', 'Enterprise'
      {:include => 'categories', :conditions => ['categories.id IN (?)', category_ids]}.merge!(options)
    else
      raise "unreconized class #{klass.name}"
    end
  end

  def options_for_find_by_initial(klass, initial)
    # FIXME copy/pasted from options_for_find above !!!
    case klass.name
    when 'Comment'
      {:select => 'distinct comments.*', :joins => 'inner join articles_categories on articles_categories.article_id = comments.article_id', :conditions => ['articles_categories.category_id in (?) and comments.title like (?)', category_ids, initial + '%']}
    when 'Product'
      {:select => 'distinct products.*', :joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id in (?) and products.name like (?)', category_ids, initial + '%']}
    when 'Article', 'Person', 'Community', 'Enterprise'
      {:include => 'categories', :conditions => ['categories.id IN (?) and %s.name like (?)' % klass.table_name, category_ids, initial + '%']}
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
