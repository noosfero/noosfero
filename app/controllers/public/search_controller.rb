class SearchController < ApplicationController  

  SEARCHES = []

  def self.search(&block)
    SEARCHES << block
  end

  protected

  #############################################
  # XXX add yours searches here
  #############################################

  search do |query|
    Article.find_by_contents(query)
  end

  search do |query|
    Profile.find_by_contents(query)
  end

  search do |query|
    Product.find_by_contents(query)
  end

  # auxiliary method to search in all defined searches and collect the results 
  def search(query)
    SEARCHES.inject([]) do |acc,finder|
      acc += finder.call(query)
    end.sort_by do |hit|
      -(relevance_for(hit))
    end
  end

  public

  include SearchHelper

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)
    @results = search(@filtered_query)
  end

  def tags
    @tags = Tag.find(:all)
  end

  def tag
    @tag = Tag.find_by_name(params[:tag])
    @tagged = @tag.taggings.map(&:taggable)
  end

  def advanced_search
    
  end

end
