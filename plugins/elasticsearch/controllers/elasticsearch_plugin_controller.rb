require_relative '../helpers/elasticsearch_helper'

class ElasticsearchPluginController < ApplicationController
  no_design_blocks
  include ElasticsearchHelper

  def index
    search()
    render :action => 'search'
  end

  def search
    define_searchable_types
    define_search_fields_types
    define_results
  end

  def define_results
    @query = params[:query]
    @results = process_results
    @hits = @results.total
  end

  def define_searchable_types
    @searchable_types = searchable_types
    @selected_type = (params[:selected_type]|| :all ).to_sym
  end

  def define_search_fields_types
    @filter_types = filters
    @selected_filter = (params[:filter] || :relevance).to_sym
  end

end
