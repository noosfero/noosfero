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

  def self.filters
    {
     :relevance      => { label: _("Relevance")},
     :lexical        => { label: _("Alphabetical")},
     :more_recent    => { label: _("More Recent")},
    }
  end

  def process_results
    selected_type = (params[:selected_type].presence|| :all).to_sym
    selected_type == :all ? search_from_all_models : search_from_model(selected_type)
  end

  private

  def search_from_all_models
    query = get_query params[:query], sort_by: get_sort_by(params[:filter])
    Elasticsearch::Model.search(query,searchable_models, size: default_per_page(params[:per_page])).page(params[:page]).records
  end

  def search_from_model model
    begin
      klass = model.to_s.classify.constantize

      query = get_query params[:query], klass: klass, sort_by: get_sort_by(params[:filter])
      klass.search(query, size: default_per_page(params[:per_page])).page(params[:page]).records
    rescue
      []
    end
  end

  def default_per_page per_page=nil
    per_page ||= 10
  end

  def get_sort_by sort_by
    case sort_by
      when "lexical"
        { "name.raw" => {"order" => "asc" }}
      when "more_recent"
        { "created_at" => {"order" => "desc"}}
    end
  end

  def searchable_models
    begin
      ElasticsearchHelper::searchable_types.except(:all).keys.map { | model | model.to_s.classify.constantize }
    rescue
      []
    end
  end

  def query_string expression="", models=[]
    return { match_all: {}  } if not expression

    {
      query_string: {
        query: "*"+expression.downcase.split.join('* *')+"*",
        fields: fields_from_models(models),
        tie_breaker: 0.4,
        minimum_should_match: "100%"
      }
    }
  end


  def query_method expression="", models=[]
    {
      query: {
        filtered: {
          query: query_string(expression,models),
          filter: {
            bool: {
              should: models.map {|model| model.filter(environment: @environment.id)}
            }
          }
        }
      }
    }
  end

  def get_query text="", options={}
    klass = options[:klass]
    sort_by = options[:sort_by]

    models = (klass.nil?) ? searchable_models : [klass]

    query = query_method(text, models)
    query[:sort] = sort_by if sort_by
    query
  end

  def fields_from_models klasses
    fields = Set.new
    klasses.each do |klass|
      klass::SEARCHABLE_FIELDS.map do |key, value|
        if value and value[:weight]
          fields.add "#{key}^#{value[:weight]}"
        else
          fields.add "#{key}"
        end
      end
    end
    fields.to_a
  end

end
