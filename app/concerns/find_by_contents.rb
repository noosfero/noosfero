module FindByContents

  def find_by_contents(asset, context, scope, query, paginate_options={:page => 1}, options={})
    scope = scope.with_templates(options[:template_id]) unless options[:template_id].blank?
    scope = scope.tagged_with(options[:tag]) unless options[:tag].blank?
    search = plugins.dispatch_first(:find_by_contents, asset, scope, query, paginate_options, options)
    register_search_term(query, scope.count, search[:results].count, context, asset)
    search
  end

  def autocomplete asset, scope, query, paginate_options={:page => 1}, options={:field => 'name'}
    plugins.dispatch_first(:autocomplete, asset, scope, query, paginate_options, options) ||
    fallback_autocomplete(asset, scope, query, paginate_options, options)
  end

  def fallback_autocomplete asset, scope, query, paginate_options, options
    field = options[:field]
    query = query.downcase
    scope.where([
      "LOWER(#{field}) ILIKE ? OR #{field}) ILIKE ?", "#{query}%", "% #{query}%"
    ])
    {:results => scope.paginate(paginate_options)}
  end

  def load_filters filters
    selected_filters = {}
    filters.each do |key, value|
      if value.is_a?(Hash)
        result = load_filters value
        selected_filters[key] = result unless result.empty?
      else
        if value.present? && value != "0" && value != ""
          selected_filters[key] = value
        end
      end
    end
    selected_filters
  end

end

