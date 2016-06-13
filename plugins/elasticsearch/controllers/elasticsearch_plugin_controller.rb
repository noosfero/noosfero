class ElasticsearchPluginController < ApplicationController
  no_design_blocks

  SEARCHABLE_TYPES = { :all       => { label: _("All Results")},
                       :community => { label: _("Communities")},
                       :event     => { label: _("Events")},
                       :person    => { label: _("People")}
                     }

  SEARCH_FILTERS   = { :lexical => { label: _("Alphabetical Order")},
                       :recent => { label: _("More Recent Order")},
                       :access => { label: _("More accessed")}
                     }

  def index
    search()
    render :action => 'search'
  end

  def search
    define_searchable_types
    define_search_fields_types

    process_results
  end

  def process_results
    @query = params[:query]

    if @selected_type == :all
      @results = search_from_all_models
    else
      @results = search_from_model @selected_type
    end
  end

  private

  def fields_from_model
    klass::SEARCHABLE_FIELDS.map do |key, value|
      if value[:weight]
        "#{key}^#{value[:weight]}"
      else
        "#{key}"
      end
    end
  end

  def get_query text, klass=nil
    query = {}
    unless text.blank?
       text = text.downcase
       query = {
         query: {
           match_all: {
           }
         },
         filter: {
           regexp: {
             name: {
               value: ".*" + text + ".*" }
           }
         },
         suggest: {
           autocomplete: {
             text: text,
             term: {
               field: "name",
               suggest_mode: "always"
             }
           }
         }

       }
    end
    query
  end


  def search_from_all_models
    models = []
    query = get_query params[:query]

    SEARCHABLE_TYPES.keys.each {| model | models.append( model.to_s.classify.constantize) if model != :all }
    Elasticsearch::Model.search(query, models, size: default_per_page).page(params[:page]).records
  end

  def search_from_model model
    begin
      klass = model.to_s.classify.constantize
      query = get_query params[:query], klass
      klass.search(query, size: default_per_page).page(params[:page]).records
    rescue
      []
    end
  end

  def define_searchable_types
    @searchable_types = SEARCHABLE_TYPES
    @selected_type = params[:selected_type].nil? ? :all : params[:selected_type].to_sym
  end

  def define_search_fields_types
    @search_filter_types = SEARCH_FILTERS
    @selected_filter_field = params[:selected_filter_field].nil? ? SEARCH_FILTERS.keys.first : params[:selected_filter_field].to_sym
  end

  def default_per_page
    10
  end

end
