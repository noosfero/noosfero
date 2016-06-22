module ElasticsearchHelper

  def self.searchable_types
    {
     :all              => { label: _("All Results")},
     :text_article     => { label: _("Articles")},
     :uploaded_file    => { label: _("Files")},
     :community        => { label: _("Communities")},
     :event            => { label: _("Events")},
     :person           => { label: _("People")}
    }
  end

  def self.search_filters
    {
     :lexical => { label: _("Alphabetical Order")},
     :recent => { label: _("More Recent Order")},
     :access => { label: _("More accessed")}
    }
  end

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

  def process_results
    selected_type = (params[:selected_type]|| :all).to_sym
    if  selected_type == :all
      search_from_all_models
    else
      search_from_model selected_type
    end
  end

  def search_from_all_models
    models = []
    query = get_query params[:query]

    ElasticsearchHelper::searchable_types.keys.each {| model | models.append( model.to_s.classify.constantize) if model != :all }
    Elasticsearch::Model.search(query, models, size: default_per_page(params[:per_page])).page(params[:page]).records
  end

  def search_from_model model
    begin
      klass = model.to_s.classify.constantize
      query = get_query params[:query], klass
      klass.search(query, size: default_per_page(params[:per_page])).page(params[:page]).records
    rescue
      []
    end
  end

  def default_per_page per_page
    per_page ||= 10
  end

end
