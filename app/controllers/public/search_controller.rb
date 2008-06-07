class SearchController < ApplicationController  

  helper TagsHelper

  before_filter :load_category
  before_filter :prepare_filter
  before_filter :check_search_whole_site
  before_filter :load_search_assets
  before_filter :check_valid_assets, :only => [ :assets, :directory ]

  no_design_blocks

  protected

  def load_search_assets
    @search_in = SEARCH_IN
    @searching = {}
    @search_in.each do |key, name|
      @searching[key] = (params[:asset].blank? && (params[:find_in].nil? || params[:find_in].empty? || params[:find_in].include?(key.to_s))) || (params[:asset] == key.to_s)
    end
  end

  def prepare_filter
    if @category
      @finder = CategoryFinder.new(@category)
    else
      @finder = EnvironmentFinder.new(@environment)
    end
  end

  def check_search_whole_site
    if params[:search_whole_site_yes] or params[:search_whole_site] == 'yes'
      redirect_to params.merge(:category_path => [], :search_whole_site => nil, :search_whole_site_yes => nil)
    end
  end

  def check_valid_assets
    @asset = params[:asset].to_sym
    if !SEARCH_IN.map(&:first).include?(@asset)
      render :text => 'go away', :status => 403
      return
    end
  end

  def events
    @events = @results[:events]
    @calendar = Event.date_range(params[:year], params[:month]).map do |date|
      [
        # the day itself
        date, 
        # list of events of that day
        @events.select do |event|
          event.date_range.include?(date)
        end,
        # is this date in the current month?
        true
      ]
    end

    # pad with days before
    while @calendar.first.first.wday != 0
      @calendar.unshift([@calendar.first.first - 1.day, [], false])
    end

    # pad with days after (until Saturday)
    while @calendar.last.first.wday != 6
      @calendar << [@calendar.last.first + 1.day, [], false]
    end

  end

  def people
    #nothing, just to enable
  end
  def enterprises
    #nothing, just to enable
  end
  def communities
    #nothing, just to enable
  end
  def articles
    #nothins, just to enable
  end

  public

  include SearchHelper

  ######################################################

  SEARCH_IN = [
    [ :articles, N_('Articles') ],
    [ :enterprises, N_('Enterprises') ],
    [ :people, N_('People') ],
    [ :communities, N_('Communities') ],
    [ :products, N_('Products') ],
    [ :events, N_('Events') ]
  ]

  # TODO don't hardcode like this >:-(
  LIST_LIMIT = 20

  def complete_region
    @regions = Region.find(:all, :conditions => [ 'name like ? and lat is not null and lng is not null', '%' + params[:region][:name] + '%' ])
    render :action => 'complete_region', :layout => false
  end

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)
    @product_category = ProductCategory.find(params[:product_category]) if params[:product_category]

    # FIXME name is not unique
    @region = Region.find_by_name(params[:region][:name]) if params[:region]

    @results = {}
    @names = {}
    SEARCH_IN.each do |key, description|
      if [:enterprises, :people].include?(key) && @region
        @results[key] = @finder.find(key, @filtered_query, :within => params[:radius], :region => @region.id, :product_category => @product_category) if @searching[key]
      else
        @results[key] = @finder.find(key, @filtered_query, :product_category => @product_category) if @searching[key]
      end
      @names[key] = gettext(description)
    end

    if @results.keys.size == 1
      specific_action = @results.keys.first
      if respond_to?(specific_action)
        @asset_name = gettext(@names[@results.keys.first])
        send(specific_action)
        render :action => specific_action
        return
      end
    end

    render :action => 'index'
  end

  def products
    @categories = @results[:products].map(&:product_category).compact
    @counts = @categories.uniq.inject({}) do |h, cat| 
      h[cat.id] = [cat, 0]
      h 
    end

    @categories.each do |cat|
      cat.hierarchy.each do |each_cat|
        @counts[each_cat.id][1] += 1 if @counts[each_cat.id]
      end
    end

    @cats = @counts.values.sort_by{|v|v[0].full_name}
  end

  alias :assets :index

  #######################################################

  # view the summary of one category
  def category_index
    @results = {}
    @names = {}
    [
      [ :people, _('Recently registered people'), @finder.recent('people') ],
      [ :communities, _('Recently created communities'), @finder.recent('communities') ],
      [ :articles, _('Recent articles'), @finder.recent('articles') ],
      [ :most_commented_articles, _('Most commented articles'), @finder.most_commented_articles ],
      [ :enterprises, _('Recently created enterprises'), @finder.recent('enterprises') ],
      [ :events, _('Recently added events'), @finder.current_events(params[:year], params[:month]) ]
    ].each do |key, name, list|
      @results[key] = list
      @names[key] = name
    end
  end
  attr_reader :category

  def directory
    @results = { @asset => @finder.find_by_initial(@asset, params[:initial]) }
    @asset_name = gettext(SEARCH_IN.find { |entry| entry.first == @asset }[1])
    @names = { @asset => @asset_name }

    render :action => @asset
  end

  def tags
    @tags = Tag.find(:all).inject({}) do |memo,tag|
      memo[tag.name] = tag.taggings.count
      memo
    end
  end

  def tag
    @tag = Tag.find_by_name(params[:tag])
    @tagged = @tag.taggings.map(&:taggable)
  end

  def sellers
    # FIXME use a better select for category
    @categories = ProductCategory.find(:all)
    @regions = Region.find(:all).select{|r|r.lat && r.lng}
    @product_category = ProductCategory.find(params[:category]) if params[:category]
    @region = Region.find(params[:region]) if params[:region]
    
    options = {}
    options.merge! :origin => [params[:lat].to_f, params[:long].to_f], :within => params[:radius] if !params[:lat].blank? && !params[:long].blank? && !params[:radius].blank?
    options.merge! :origin => [@region.lat, @region.lng], :within => params[:radius] if !params[:region].blank? && !params[:radius].blank?
    if @product_category
      finder = CategoryFinder.new(@product_category)
      product_ids = finder.find('products',nil)
      options.merge! :include => :products, :conditions => ['products.id IN ?', product_ids ]
    end

    @enterprises = Enterprise.find(:all, options)
  end

  #######################################################

  def popup
    @regions = Region.find(:all).select{|r|r.lat && r.lng}
    render :action => 'popup', :layout => false
  end

end
