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

    @results = {
      :articles => search(@finder.articles, @filtered_query), 
      :comments => search(@finder.comments, @filtered_query),
      :enterprises => search(@finder.enterprises, @filtered_query),
      :people => search(@finder.people, @filtered_query),
    }
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
