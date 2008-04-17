class SearchController < ApplicationController  

  helper TagsHelper

  before_filter :load_category
  before_filter :prepare_filter
  before_filter :check_search_whole_site

  protected

  def search(finder, query)
    finder.find_by_contents(query).sort_by(&:created_at).sort_by do |hit|
      -(relevance_for(hit))
    end
  end

  def prepare_filter
    @finder = @category || @environment
  end

  def check_search_whole_site
    if params[:search_whole_site] == 'yes'
      redirect_to params.merge(:category_path => [], :search_whole_site => nil)
    end
  end

  def action_product_category
    @products = category.products
    @enterprises = category.products.map{|p| p.enterprise}.flatten.uniq
    @users = category.consumers
  end

  def action_category
    @recent_articles = category.recent_articles
    @recent_comments = category.recent_comments
    @most_commented_articles = category.most_commented_articles
  end
  alias :action_region :action_category

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
  LIST_LIMIT = 10

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)

    @results = {}
    @names = {}
    SEARCH_IN.each do |key, description|
      @results[key] = search(@finder.send(key), @filtered_query) if params[:find_in].nil? || params[:find_in].empty? || params[:find_in].include?(key.to_s)
      @names[key] = gettext(description)
    end
  end

  #######################################################

  # view the summary of one category
  def category_index
    send('action_' + @category.class.name.underscore) 
  end
  attr_reader :category

  def assets
    asset = params[:asset].to_sym
    if !SEARCH_IN.map(&:first).include?(asset)
      render :text => 'go away', :status => 403
      return
    end


    @results = { asset => @finder.send(asset).recent(LIST_LIMIT) }

    @asset_name = gettext(SEARCH_IN.find { |entry| entry.first == asset }[1])
    @names = { asset => @asset_name }
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

  #######################################################

  def popup
    @search_in = SEARCH_IN
    render :action => 'popup', :layout => false
  end

end
