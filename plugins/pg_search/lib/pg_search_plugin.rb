require 'noosfero/friendly_mime'

class PgSearchPlugin < Noosfero::Plugin

  def self.plugin_name
    "Postgres Full-Text Search"
  end

  def self.plugin_description
    _("Search engine that uses Postgres Full-Text Search.")
  end

  def stylesheet?
    true
  end

  def search_facets?
    true
  end

  def js_files
    'search.js'
  end

  def find_by_contents(asset, scope, query, paginate_options={}, options={})
    facets = options[:facets] || {}
    periods = options[:periods] || {:created_at => nil, :updated_at => nil}

    @base_scope = scope
    @asset = asset

    scope = scope.send(options[:filter]) if options[:filter] && options[:filter] != 'more_relevant'

    scope = filter_by_periods(scope, periods) if options[:periods].present?
    scope = filter_by_facets(scope, facets) if options[:facets].present?

    if query.present?
      query_scope = @base_scope.pg_search_plugin_search(query)
      #TODO The reorder is necessary to avoid crashes with core scopes chain
      scope = query_scope.where(:id => scope.map(&:id)).reorder("")
    end

    {:results => scope.paginate(paginate_options), :facets => facets_options(asset, scope, facets), :periods => periods}
  end

  private

  def filter_by_periods(scope, periods)
    periods.each do |attribute, period|
      next if period.blank?
      scope = scope.send(attribute, period['start_date'], period['end_date'])
    end
    scope
  end

  def filter_by_facets(scope, facets)
    queries = []
    facets.each do |term, values|
      kind, klass = term.split('-')
      if kind == 'attribute' || kind == 'relation'
        arguments = values.map {|value, check| value if check == '1'}.compact
        arguments.map! {|argument| argument == ' ' ? nil : argument}
      else
        next
      end
      facet_slug = klass.split('/').last
      arguments.each do |argument|
        if kind == 'attribute'
          queries << scope.base_class.send('pg_search_plugin_by_attribute', facet_slug, argument).to_sql
        elsif kind == 'relation'
          queries << scope.base_class.send("pg_search_plugin_by_#{facet_slug}", argument).to_sql
        end
        register_search_facet_occurrence(environment, @asset, kind, facet_slug, argument)
      end
    end
    queries.blank? ? scope : scope.where(:id => scope.base_class.find_by_sql(queries.join(' INTERSECT ')))
  end

  def facets_options(asset, scope, selected_facets)
    self.send("#{asset}_facets", scope, selected_facets).compact
  end

  def articles_facets(scope, selected_facets)
    [
      attribute_facet(Article, scope, selected_facets, {:attribute => :type}),
      attribute_facet(Article, scope, selected_facets, {:attribute => :content_type}),
      relation_facet(Tag, scope, selected_facets),
      relation_facet(Category, scope, selected_facets, {:filter => :pg_search_plugin_articles_facets})
    ]
  end

  def profiles_facets(scope, selected_facets)
    [
      relation_facet(Kind, scope, selected_facets),
      relation_facet(Tag, scope, selected_facets),
      relation_facet(Category, scope, selected_facets, {:filter => :pg_search_plugin_profiles_facets}),
      relation_facet(Region, scope, selected_facets),
    ]
  end
  alias :people_facets :profiles_facets
  alias :communities_facets :profiles_facets
  alias :enterprises_facets :profiles_facets

  def events_facets(scope, selected_facets)
    []
  end

  def attribute_facet(klass, scope, selected_facets, params = {})
    generic_facet(klass, scope, selected_facets, :attribute, params)
  end

  def relation_facet(klass, scope, selected_facets, params = {:filter => :pg_search_plugin_facets})
    generic_facet(klass, scope, selected_facets, :relation, params)
  end

  def generic_facet(klass, scope, selected_facets, kind, params = {})
    no_results = false
    results = self.send("#{kind}_results", klass, scope, params)
    if results.blank?
      no_results = true
      results = self.send("#{kind}_results", klass, @base_scope, params)
    end

    identifier = self.send("#{kind}_identifier", klass, params)
    options = results.map do |result|
      value = result[:value].blank? ? ' ' : result[:value].to_s
      name = self.send("#{kind}_option_name", result[:name], klass, params)
      enabled = selected_facets[identifier] && selected_facets[identifier][value] == '1'
      count = no_results ? 0 : result[:count]
      {:label => name, :value => value, :count => count, :enabled => enabled, :identifier => identifier}
    end.compact

    return if options.blank?

    {:name => self.send("#{kind}_label", klass, params), :options => options}
  end

  def attribute_identifier(klass, params)
    "attribute-#{params[:attribute]}"
  end

  def attribute_label(klass, params)
    params[:attribute].to_s.humanize.pluralize
  end

  def attribute_option_name(name, klass, params)
    return nil if name.blank?
    if params[:attribute].to_s == 'content_type'
      Noosfero::FriendlyMIME.find(name)[1..-1].upcase
    else
      name
    end
  end

  def attribute_results(klass, scope, params)
    results = klass.pg_search_plugin_attribute_facets(scope, params[:attribute]).count
    results.map do |name, count|
      {:name => name, :value => name, :count => count}
    end
  end

  def relation_identifier(klass, params)
    "relation-#{klass.name.underscore}"
  end

  def relation_label(klass, params)
    klass.name.split('::').last.pluralize
  end

  def relation_option_name(name, klass, params)
    name
  end

  def relation_results(klass, scope, params)
    results = klass.send(params[:filter], scope).
      select("#{klass.table_name}.*, count(#{klass.table_name}.*) as counts").
      order("counts DESC")

    results.map do |result|
      {:name => relation_result_label(result), :value => result.id, :count => result.counts}
    end
  end

  def relation_result_label_for_category(result)
    result.full_name(' &rarr; ').html_safe
  end

  def relation_result_label(result)
    klass = result.class
    loop do
      method_name = "relation_result_label_for_#{klass.name.demodulize.underscore}"
      begin
        return self.send(method_name, result)
      rescue NoMethodError
        klass = klass.superclass
        return result.name if klass == ActiveRecord::Base
      end
    end
  end

  def register_search_facet_occurrence(environment, asset, kind, facet_slug, argument)
    occurrence = PgSearchPlugin::SearchFacetOccurrence.new(:environment => environment, :asset => asset)
    case kind
    when 'attribute'
      occurrence.attribute_name = facet_slug
      occurrence.value = argument
    when 'relation'
      klass_name = facet_slug.classify
      occurrence.target = klass_name.constantize.where(id: argument).first
    else
      return
    end
    occurrence.save!
    occurrence
  end

  def translations
    _('Created at')
    _('Updated at')
    _('Types')
    _('TextArticle')
    _('UploadedFile')
    _('RSSFeed')
    _('Content types')
    _('Tags')
  end
end
