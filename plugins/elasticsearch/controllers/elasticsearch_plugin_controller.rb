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

    process_results
  end

end
