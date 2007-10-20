class SearchController < ApplicationController  
  def index
    @query = params[:query] || ''
    @results = Article.find_tagged_with(@query) + Article.find_by_contents(@query)
  end
end
