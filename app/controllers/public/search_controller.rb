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
      @searching[key] = params[:find_in].nil? || params[:find_in].empty? || params[:find_in].include?(key.to_s)
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
    if params[:search_whole_site] == 'yes'
      redirect_to params.merge(:category_path => [], :search_whole_site => nil)
    end
  end

  def check_valid_assets
    @asset = params[:asset].to_sym
    if !SEARCH_IN.map(&:first).include?(@asset)
      render :text => 'go away', :status => 403
      return
    end
  end

  public

  include SearchHelper

  ######################################################

  SEARCH_IN = [
    [ :articles, N_('Articles') ],
    [ :comments, N_('Comments') ],
    [ :enterprises, N_('Enterprises') ],
    [ :people, N_('People') ],
    [ :communities, N_('Communities') ],
    [ :products, N_('Products') ]
  ]

  # TODO don't hardcode like this >:-(
  LIST_LIMIT = 20

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)

    @results = {}
    @names = {}
    SEARCH_IN.each do |key, description|
      @results[key] = @finder.find(key, @filtered_query) if @searching[key]
      @names[key] = gettext(description)
    end
  end

  #######################################################

  # view the summary of one category
  def category_index
    @results = {}
    @names = {}
    [
      [ :recent_people, _('Recently registered people'), @finder.recent('people') ],
      [ :recent_communities, _('Recently created communities'), @finder.recent('communities') ],
      [ :recent_articles, _('Recent articles'), @finder.recent('articles') ],
      [ :comments, _('Recent comments'), @finder.recent('comments') ],
      [ :most_commented_articles, _('Most commented articles'), @finder.most_commented_articles ],
      [ :recent_enterptises, _('Recently created enterprises'), @finder.recent('enterprises') ]
    ].each do |key, name, list|
      @results[key] = list
      @names[key] = name
    end
  end
  attr_reader :category

  def assets
    @results = { @asset => @finder.recent(@asset, LIST_LIMIT) }

    @asset_name = gettext(SEARCH_IN.find { |entry| entry.first == @asset }[1])
    @names = { @asset => @asset_name }
  end

  def directory
    @results = { @asset => @finder.find_by_initial(@asset, params[:initial]) }

    # FIXME remove this duplication with assets action
    @asset_name = gettext(SEARCH_IN.find { |entry| entry.first == @asset }[1])
    @names = { @asset => @asset_name }

    render :action => 'assets'
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
    @categories = ProductCategory.find(:all)
    @regions = Region.find(:all).select{|r|r.lat && r.lng}
    @product_category = ProductCategory.find(params[:category]) if params[:category]
    @region = Region.find(params[:region]) if params[:region]
    options = {}
    options.merge!({:include => :products, :conditions => ['products.product_category_id = ?', @product_category.id]}) if @product_category
    options.merge!({:origin => [params[:lat].to_f, params[:long].to_f], :within => params[:radius] }) if params[:lat] && params[:long] && params[:radius]
    @enterprises = Enterprise.find(:all, options)
  end

  #######################################################

  def popup
    render :action => 'popup', :layout => false
  end

end
