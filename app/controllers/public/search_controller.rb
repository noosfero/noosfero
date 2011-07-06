class SearchController < PublicController

  MAP_SEARCH_LIMIT = 2000
  SINGLE_SEARCH_LIMIT = 20
  MULTIPLE_SEARCH_LIMIT = 6

  helper TagsHelper
  include SearchHelper

  before_filter :load_category
  before_filter :load_search_assets

  no_design_blocks

  def articles
    @asset = :articles
    @query = params[:query] || ''
    @order ||= [@asset]
    @results ||= {}
    @filter = filter

    pg_options = paginate_options(@asset, limit, params[:per_page])
    if !@query.blank?
      ret = asset_class(@asset).find_by_contents(@query, pg_options, solr_options(@asset, params[:facet], params[:order_by]))
      @results[@asset] = ret[:results]
      @facets = ret[:facets]
    else
      @results[@asset] = asset_class(@asset).send('paginate', :all, pg_options)
      @facets = {}
    end
  end

  alias :contents :articles 

  def people
    @asset = :people
    @query = params[:query] || ''
    @order ||= [@asset]
    @results ||= {}
    @filter = filter
    @title = self.filter_description(params[:action] + '_' + @filter )

    @results[@asset] = @environment.people.visible.send(@filter)
    if !@query.blank?
      ret = @results[@asset].find_by_contents(@query, {}, solr_options(@asset, params[:facet], params[:order_by]))
      @results[@asset] = ret[:results]
      @facets = ret[:facets]
    else
      @facets = {}
    end
    @results[@asset] = @results[@asset].compact.paginate(:per_page => limit, :page => params[:page])
  end

  def products
    @asset = :products
    @query = params[:query] || ''
    @order ||= [@asset]
    @results ||= {}

    pg_options = paginate_options(@asset, limit, params[:per_page])
    if !@query.blank?
      ret = asset_class(@asset).find_by_contents(@query, pg_options, solr_options(@asset, params[:facet], params[:order_by]))
      @results[@asset] = ret[:results]
      @facets = ret[:facets]
    else
      @results[@asset] = asset_class(@asset).send('paginate', :all, pg_options)
      @facets = {}
    end
  end

  def enterprises
    @asset = :enterprises
    @query = params[:query] || ''
    @order ||= [@asset]
    @results ||= {}

    pg_options = paginate_options(@asset, limit, params[:per_page])
    if !@query.blank?
      ret = asset_class(@asset).find_by_contents(@query, pg_options, solr_options(@asset, params[:facet], params[:order_by]))
      @results[@asset] = ret[:results]
      @facets = ret[:facets]
    else
      @results[@asset] = asset_class(@asset).send('paginate', :all, pg_options)
      @facets = {}
    end
  end

  def communities
    @asset = :communities
    @query = params[:query] || ''
    @order ||= [@asset]
    @results ||= {}
    @filter = filter
    @title = self.filter_description(params[:action] + '_' + @filter )

    @results[@asset] = @environment.communities.visible.send(@filter)
    if !@query.blank?
      ret = @results[@asset].find_by_contents(@query, {}, solr_options(@asset, params[:facet], params[:order_by]))
      @results[@asset] = ret[:results]
      @facets = ret[:facets]
    else
      @facets = {}
    end
    @results[@asset] = @results[@asset].compact.paginate(:per_page => limit, :page => params[:page])
  end

  def events
    @asset = :events
    params[:asset] |= [@asset]
    @query = params[:query] || ''
    @order ||= [@asset]
    @results ||= {}
    @category_id = @category ? @category.id : nil

    if params[:year] || params[:month]
      date = Date.new(year.to_i, month.to_i, 1)
      date_range = (date - 1.month)..(date + 1.month).at_end_of_month
    end

    if @query.blank?
      # Ignore pagination for asset events
      if date_range
        @results[@asset] = Event.send('find', :all, 
          :conditions => [
            'start_date BETWEEN :start_day AND :end_day OR end_date BETWEEN :start_day AND :end_day',
            {:start_day => date_range.first, :end_day => date_range.last}
        ])
      else
        @results[@asset] = Event.send('find', :all)
      end
    else
      pg_options = paginate_options(@asset, limit, params[:per_page])
      solr_options = solr_options(@asset, params[:facet], params[:per_page])
      @results[@asset] = Event.find_by_contents(@query, pg_options, solr_options)[:results]
    end

    @selected_day = nil
    @events_of_the_day = []
    date = build_date(params[:year], params[:month], params[:day])

    if params[:day] || !params[:year] && !params[:month]
      @selected_day = date
      if @category_id and Category.exists?(@category_id)
        @events_of_the_day = environment.events.by_day(@selected_day).in_category(Category.find(@category_id))
      else
        @events_of_the_day = environment.events.by_day(@selected_day)
      end
    end

    events = @results[@asset]
    @calendar = populate_calendar(date, events)
    @previous_calendar = populate_calendar(date - 1.month, events)
    @next_calendar = populate_calendar(date + 1.month, events)
  end

  def index
    @results = {}
    @order = []
    @names = {}

    @enabled_searchs.select { |key,description| @searching[key] }.each do |key, description|
      send(key)
      @order << key
      @names[key] = getterm(description)
    end
    @asset = nil
    @facets = {}

    if @results.keys.size == 1
      specific_action = @results.keys.first
      if respond_to?(specific_action)
        @asset_name = getterm(@names[@results.keys.first])
        send(specific_action)
        render :action => specific_action
        return
      end
    end
  end

  alias :assets :index

  # view the summary of one category
  def category_index
    @results = {}
    @order = []
    @names = {}
    limit = MULTIPLE_SEARCH_LIMIT
    [
      [ :people, _('People'), recent('people', limit) ],
      [ :enterprises, __('Enterprises'), recent('enterprises', limit) ],
      [ :products, _('Products'), recent('products', limit) ],
      [ :events, _('Upcoming events'), upcoming_events({:per_page => limit}) ],
      [ :communities, __('Communities'), recent('communities', limit) ],
      [ :most_commented_articles, _('Most commented articles'), most_commented_articles(limit) ],
      [ :articles, _('Articles'), recent('text_articles', limit) ]
    ].each do |key, name, list|
      @order << key
      @results[key] = list
      @names[key] = name
    end
    @facets = {}
  end

  def tags
    @tags_cache_key = "tags_env_#{environment.id.to_s}"
    if is_cache_expired?(@tags_cache_key, true)
      @tags = environment.tag_counts
    end
  end

  def tag
    @tag = params[:tag]
    @tag_cache_key = "tag_#{CGI.escape(@tag.to_s)}_env_#{environment.id.to_s}_page_#{params[:npage]}"
    if is_cache_expired?(@tag_cache_key, true)
      @tagged = environment.articles.find_tagged_with(@tag).paginate(:per_page => 10, :page => params[:npage])
    end
  end

  def events_by_day
    @selected_day = build_date(params[:year], params[:month], params[:day])
    if params[:category_id] and Category.exists?(params[:category_id])
      @events_of_the_day = environment.events.by_day(@selected_day).in_category(Category.find(params[:category_id]))
    else
      @events_of_the_day = environment.events.by_day(@selected_day)
    end
    render :partial => 'events/events_by_day'
  end

  #######################################################
  protected

  def recent(asset, limit = nil)
    options = {:page => 1, :per_page => limit, :order => 'created_at DESC, id DESC'}

    if asset == :events
      finder_method = 'find'
      options.delete(:page)
      options.delete(:per_page)
    else
      finder_method = 'paginate'
    end

    asset_class(asset).send(finder_method, :all, category_options_for_find(asset_class(asset), {:order => "#{asset_table(asset)}.name"}.merge(options)))
  end

  def most_commented_articles(limit=10, options={})
    options = {:page => 1, :per_page => limit, :order => 'comments_count DESC'}.merge(options)
    Article.paginate(:all, category_options_for_find(Article, options))
  end

  def upcoming_events(options = {})
    options.delete(:page)
    options.delete(:per_page)

    Event.find(:all, {:include => :categories, :conditions => [ 'categories.id = ? and start_date >= ?', category_id, Date.today ], :order => 'start_date' }.merge(options))
  end

  def current_events(year, month, options={})
    options.delete(:page)
    options.delete(:per_page)

    range = Event.date_range(year, month)

    Event.find(:all, {:include => :categories, :conditions => { 'categories.id' => category_id, :start_date => range }}.merge(options))
  end

  FILTERS = %w(
    more_recent
    more_active
    more_popular
  )
  def filter
    if FILTERS.include?(params[:filter])
      params[:filter]
    else
      'more_recent'
    end
  end

  def filter_description(str)
    {
      'contents_more_recent' => _('More recent contents'),
      'contents_more_popular' => _('More popular contents'),
      'people_more_recent' => _('More recent people'),
      'people_more_active' => _('More active people'),
      'people_more_popular' => _('More popular people'),
      'communities_more_recent' => _('More recent communities'),  
      'communities_more_active' => _('More active communities'),  
      'communities_more_popular' => _('More popular communities'),
    }[str] || str
  end

  attr_reader :category
  attr_reader :category_id

  def load_category
    unless params[:category_path].blank?
      path = params[:category_path].join('/')
      @category = environment.categories.find_by_path(path)
      if @category.nil?
        render_not_found(path)
      end
      @category_id = @category.id
    end
  end

  def load_search_assets
    @enabled_searchs = [
      [ :articles, N_('Articles') ],
      [ :enterprises, N_('Enterprises') ],
      [ :people, N_('People') ],
      [ :communities, N_('Communities') ],
      [ :products, N_('Products') ],
      [ :events, N_('Events') ]
    ].select {|key, name| !environment.enabled?('disable_asset_' + key.to_s) }

    @searching = {}
    @enabled_searchs.each do |key, name|
      @searching[key] = params[:action] == 'index' || params[:action] == key.to_s
    end
  end

  def paginate_options(asset, limit, page)
    result = { :per_page => limit, :page => page }
  end

  def solr_options(asset, facet, solr_order)
    result = {}

    if asset_class(asset).methods.include?('facets')
      result.merge!(:facets => {:zeros => false, :sort => :count, :fields => asset_class(asset).facets.keys,
                    :browse => facet ? facet.map{ |k,v| k.to_s+':"'+v.to_s+'"'} : ''})
    end

    if solr_order
      result[:order_by] = solr_order
    end

    result
  end

  def limit
    searching = @searching.values.select{|v|v}
    if params[:display] == 'map'
      MAP_SEARCH_LIMIT
    else
      (searching.size <= 1) ? SINGLE_SEARCH_LIMIT : MULTIPLE_SEARCH_LIMIT
    end
  end

  def category_options_for_find(klass, options={}, date_range = nil)
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
          ['articles_categories.category_id = (:category_id) and (start_date BETWEEN :start_day AND :end_day OR end_date BETWEEN :start_day AND :end_day)', {:category_id => category_id, :start_day => date_range.first, :end_day => date_range.last} ]
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
