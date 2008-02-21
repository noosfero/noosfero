class SearchController < ApplicationController  

  helper TagsHelper

  protected

  def search(klass, query)
    klass.find_by_contents(query).sort_by do |hit|
      -(relevance_for(hit))
    end
  end

  public

  include SearchHelper

  def index
    @query = params[:query] || ''
    @filtered_query = remove_stop_words(@query)
    @articles, @people, @enterprises, @communities, @products = 
      [Article, Person, Enterprise, Community, Product].map{ |klass| search(klass, @query) }
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

  def popup
    render :action => 'popup', :layout => false
  end

end
