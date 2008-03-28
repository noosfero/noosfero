class SearchController < ApplicationController  

  helper TagsHelper

  before_filter :load_category
  before_filter :prepare_filter
  before_filter :check_search_whole_site

  protected

  def search(finder, query)
    finder.find_by_contents(query).sort_by do |hit|
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

  public

  include SearchHelper

  ######################################################

  SEARCH_IN = [
    [ :articles, _('Articles') ],
    [ :comments, _('Comments') ],
    [ :enterprises, _('Enterprises') ],
    [ :people, _('People') ],
    [ :communities, _('Communities') ],
    [ :products, _('Products') ]
  ]

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)

    @results = {}
    @names = {}
    SEARCH_IN.each do |key, description|
      @results[key] = search(@finder.send(key), @filtered_query) if params[:find_in].nil? || params[:find_in].empty? || params[:find_in].include?(key.to_s)
      @names[key] = description
    end
  end

  #######################################################

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
