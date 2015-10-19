module FindByContents

  def find_by_contents(asset, context, scope, query, paginate_options={:page => 1}, options={})
    scope = scope.with_templates(options[:template_id]) unless options[:template_id].blank?
    search = plugins.dispatch_first(:find_by_contents, asset, scope, query, paginate_options, options)
    register_search_term(query, scope.count, search[:results].count, context, asset)
    search
  end

end

