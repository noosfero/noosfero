class SearchController < ApplicationController  
  def index
    @query = params[:query] || ''
    # TODO: uncomment find_by_contents when ferret start working 
    @results = Article.find_tagged_with(@query) #+ Article.find_by_contents(@query)
  end
end
