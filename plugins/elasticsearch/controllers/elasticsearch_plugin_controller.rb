class ElasticsearchPluginController < ApplicationController
  no_design_blocks

  SEARCHABLE_MODELS = {communities: true, articles: true, people: true}

  def index
    search()
    render :action => 'search'
  end

  def search
    @results = []
    @query = params[:q]
    @checkbox = {}

    if params[:model].present?
        params[:model].keys.each do |model|
        @checkbox[model.to_sym] = true
        results model
      end
    else
      unless params[:q].blank?
        SEARCHABLE_MODELS.keys.each do |model|
          results model
        end
      end
    end

  end

  private

  def get_query text, klass
    query = {}
    unless text.blank?
       text = text.downcase
       fields = klass::SEARCHABLE_FIELDS.map do |key, value|
         if value[:weight]
           "#{key}^#{value[:weight]}"
         else
           "#{key}"
         end
       end

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

  def get_terms params
    terms = {}
    return terms unless params[:filter].present?
    params[:filter].keys.each do |model|
      terms[model] = {}
      params[:filter][model].keys.each do |filter|
        @checkbox[filter.to_sym] = true
        terms[model][params[:filter][model.to_sym][filter]] = filter
      end
    end
    terms
  end

  def results model
    klass = model.to_s.classify.constantize
    query = get_query params[:q], klass
    @results |= klass.__elasticsearch__.search(query).records.to_a
  end

end
