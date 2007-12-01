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
    Article.find_tagged_with(query)
  end

  search do |query|
    Article.find_by_contents(query)
  end

  search do |query|
    Profile.find_by_contents(query)
  end

  # auxiliary method to search in all defined searches and collect the results 
  def search(query)
    SEARCHES.inject([]) do |acc,finder|
      acc += finder.call(query)
    end.sort_by do |hit|
      (hit.respond_to? :ferret_score) ? (1.0 - hit.ferret_score) : (-1.0)
    end
  end

  public

  def index
    @query = params[:query] || ''
    @results = search(@query)
  end

end
