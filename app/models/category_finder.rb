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
    Product.find_by_contents(query, {}, {:select => 'products.*', :joins => 'inner join categories_profiles on products.enterprise_id = categories_profiles.profile_id', :conditions => ['categories_profiles.category_id in (?)', category_ids]}.merge!(options))
  end

  def comments(query='*', options={})
    Comment.find_by_contents(query, {}, {:select => 'comments.*', :joins => 'inner join articles_categories on articles_categories.article_id = comments.article_id', :conditions => ['articles_categories.category_id in (?)', category_ids]}.merge!(options))
  end

  def recent(asset, limit = 10)
    table = case asset
              when 'people', 'communities', 'enterprises'
                'profiles'
              else
                asset
              end

    with_options :limit => limit, :order => "created_at desc, #{table}.id desc" do |finder|
      finder.send(asset, '*', {})
    end
  end

  def count(asset)
    send(asset).size
  end

  protected

  def find_in_categorized(klass, query, options={})
    klass.find_by_contents(query, {}, {:include => 'categories', :conditions => ['categories.id IN (?)', category_ids]}.merge!(options))
  end
end
