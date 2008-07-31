class SearchController < ApplicationController  

  helper TagsHelper

  before_filter :load_category
  before_filter :prepare_filter
  before_filter :check_search_whole_site
  before_filter :load_search_assets
  before_filter :check_valid_assets, :only => [ :assets ]

  no_design_blocks

  protected

  def load_search_assets
    @search_in = where_to_search
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
    if !where_to_search.map(&:first).include?(@asset)
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
    load_product_categories_menu(:enterprises)
    @categories_menu = true
  end
  def communities
    #nothing, just to enable
  end
  def articles
    #nothins, just to enable
  end

  def products
    load_product_categories_menu(:products)
    @categories_menu = true
  end

  def load_product_categories_menu(asset)
    @results[asset].uniq!
    # REFACTOR DUPLICATED CODE inner loop doing the same thing that outter loop

    if !@query.blank? || @region && !params[:radius].blank?
      @result_ids = @finder.find(asset, @filtered_query, calculate_find_options(asset, nil, params[:page], @product_category, @region, params[:radius], params[:year], params[:month]).merge({:limit => :all}))
    end

  end

  def calculate_find_options(asset, limit, page, product_category, region, radius, year, month)
    result = { :product_category => product_category, :per_page => limit, :page => page }
    if [:enterprises, :people, :products].include?(asset) && region
      result.merge!(:within => radius, :region => region.id)
    end

    if month || year
      result[:date_range] = Event.date_range(year, month)
    end

    result
  end

  # limit the number of results per page
  # TODO: dont hardcore like this
  def limit
    searching = @searching.values.select{|v|v}
    if params[:display] == 'map'
      100
    else
      (searching.size == 1) ? 20 : 6
    end
  end

  public

  include SearchHelper

  ######################################################

  def where_to_search
    [
      [ :articles, N_('Articles') ],
      [ :enterprises, N_('Enterprises') ],
      [ :people, N_('People') ],
      [ :communities, N_('Communities') ],
      [ :products, N_('Products') ],
      [ :events, N_('Events') ]
    ].select {|key, name| !environment.enabled?('disable_asset_' + key.to_s) }
  end

  def cities
    @cities = City.find(:all, :order => 'name', :conditions => ['parent_id = ? and lat is not null and lng is not null', params[:state_id]])
    render :action => 'cities', :layout => false
  end
  
  def complete_region
    # FIXME this logic should be in the model
    @regions = Region.find(:all, :conditions => [ '(name like ? or name like ?) and lat is not null and lng is not null', '%' + params[:region][:name] + '%', '%' + params[:region][:name].capitalize + '%' ])
    render :action => 'complete_region', :layout => false
  end

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)
    @product_category = ProductCategory.find(params[:product_category]) if params[:product_category]

    @region = City.find_by_id(params[:city]) if !params[:city].blank? && params[:city] =~ /^\d+$/

    # how many assets we are searching for?
    number_of_result_assets = @searching.values.select{|v| v}.size

    @results = {}
    @order = []
    @names = {}

    where_to_search.select { |key,description| @searching[key]  }.each do |key, description|
      @order << key
      @results[key] = @finder.find(key, @filtered_query, calculate_find_options(key, limit, params[:page], @product_category, @region, params[:radius], params[:year], params[:month]))
      @names[key] = getterm(description)
    end

    if @results.keys.size == 1
      specific_action = @results.keys.first
      if respond_to?(specific_action)
        @asset_name = getterm(@names[@results.keys.first])
        send(specific_action)
        render :action => specific_action
        return
      end
    end

    render :action => 'index'
  end

  alias :assets :index

  #######################################################

  # view the summary of one category
  def category_index
    @results = {}
    @order = []
    @names = {}
    [
      [ :people, _('People'), @finder.recent('people', limit) ],
      [ :enterprises, __('Enterprises'), @finder.recent('enterprises', limit) ],
      [ :products, _('Products'), @finder.recent('products', limit) ],
      [ :events, _('Upcoming events'), @finder.upcoming_events({:per_page => limit}) ],
      [ :communities, __('Communities'), @finder.recent('communities', limit) ],
      [ :most_commented_articles, _('Most commented articles'), @finder.most_commented_articles(limit) ],
      [ :articles, _('Articles'), @finder.recent('text_articles', limit) ]
    ].each do |key, name, list|
      @order << key
      @results[key] = list
      @names[key] = name
    end
  end
  attr_reader :category

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

  #######################################################

  def popup
    @regions = Region.find(:all).select{|r|r.lat && r.lng}
    render :action => 'popup', :layout => false
  end

end
