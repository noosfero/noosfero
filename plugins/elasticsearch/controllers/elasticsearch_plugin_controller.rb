require_relative '../helpers/elasticsearch_helper'
require_relative '../helpers/elasticsearch_plugin_helper'

class ElasticsearchPluginController < ApplicationController
  no_design_blocks
  include ElasticsearchHelper
  helper ElasticsearchPluginHelper

  def index
    search()
    render :action => 'search'
  end

  def search
    define_searchable_types
    define_sort_types
    define_categories
    define_results
  end

  def define_results
    @query = params[:query]
    @results = process_results
    @hits = @results.total
  end

  def define_searchable_types
    @searchable_types = searchable_types
    @selected_type = (params[:selected_type] || :all).to_sym
  end

  def define_sort_types
    @sort_types = sort_types
    @selected_sort = (params[:filter] || :relevance).to_sym
  end

  def define_categories
    @categories = Category.where(parent: nil)
    @selected_categories = (params[:categories] || "").split(",")
  end

end
