class SearchController < ApplicationController  

  helper TagsHelper

  protected

  def search(finder, query)
    finder.find_by_contents(query).sort_by do |hit|
      -(relevance_for(hit))
    end
  end

  public

  include SearchHelper

  ######################################################

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)

    @finder ||= @environment
    
    @results = {}
    [:articles, :comments, :enterprises, :people, :communities, :products].each do |key|
      @results[key] = search(@finder.send(key), @filtered_query) if params[:find_in].nil? || params[:find_in].empty? || params[:find_in].include?(key.to_s)
    end
  end

  before_filter :load_category, :only => :filter
  def filter
    @finder = @category
    index
    render :action => 'index'
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
    render :action => 'popup', :layout => false
  end

end
