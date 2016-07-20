module ElasticsearchHelper

  def searchable_types
    {
     :all              =>  _("All results"),
     :text_article     =>  _("Articles"),
     :uploaded_file    =>  _("Files"),
     :community        =>  _("Communities"),
     :event            =>  _("Events"),
     :person           =>  _("People")
    }
  end

  def sort_types
    sorts = {
     :relevance      => _("Relevance"),
     :lexical        => _("Alphabetical"),
     :more_recent    => _("More recent")
    }

    selected_type = (params[:selected_type] || nil)

    if selected_type and selected_type.to_sym != :all
      klass = selected_type.to_s.classify.constantize
      sorts.update klass.specific_sort if klass.respond_to? :specific_sort
    end
    sorts
  end

  def process_results
    selected_type = (params[:selected_type].presence|| :all).to_sym
    selected_type == :all ? search_from_all_models : search_from_model(selected_type)
  end

  private

  def search_from_all_models
    begin
      filter = (params[:filter] || "").to_sym
      query = get_query params[:query], sort_by: get_sort_by(filter), categories: params[:categories]
      Elasticsearch::Model.search(query,searchable_models, size: default_per_page(params[:per_page])).page(params[:page]).records
    rescue
      []
    end
  end

  def search_from_model(model)
    begin
      klass = model.to_s.classify.constantize
      filter = (params[:filter] || "").to_sym
      query = get_query params[:query], klass: klass, sort_by: get_sort_by(filter ,klass), categories: params[:categories]
      klass.search(query, size: default_per_page(params[:per_page])).page(params[:page]).records
    rescue
      []
    end
  end

  def default_per_page(per_page=nil)
    per_page || 10
  end

  def get_sort_by(sort_by, klass=nil)
    case sort_by
      when :lexical
        {"name.raw" => {"order" => "asc"}}
      when :more_recent
        {"created_at" => {"order" => "desc"}}
      else
        (klass and klass.respond_to?(:get_sort_by)) ? klass.get_sort_by(sort_by) : nil
    end
  end

  def searchable_models
    searchable_types.except(:all).keys.map {|model| model.to_s.classify.constantize}
  end

  def query_string(expression="", models=[])
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


  def query_method(expression="", models=[], categories=[])
    query = {}
    current_user ||= nil

    query[:query] = {
      filtered: {
        query: query_string(expression, models),
        filter: {
          bool: {}
        }
      }
    }

    query[:query][:filtered][:filter][:bool] = {
      should: models.map {|model| model.filter(environment: @environment.id, user: current_user )}
    }

    unless categories.blank?
      query[:query][:filtered][:filter][:bool][:must] = models.first.filter_category(categories)
    end

    query
  end

  def get_query(text="", options={})
    klass = options[:klass]
    sort_by = options[:sort_by]
    categories = (options[:categories] || "").split(",")
    categories = categories.map(&:to_i)

    models = (klass.nil?) ? searchable_models : [klass]

    query = query_method(text, models, categories)
    query[:sort] = sort_by if sort_by

    query
  end

  def fields_from_models(klasses)
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
