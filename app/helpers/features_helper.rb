module FeaturesHelper
  def select_organization_approval_method(object, method)
    choices = [
      [ _('Administrator must approve all new organizations'), 'admin'],
      [ _('Administrator assigns validator organizations per region.'), 'region'],
      [ _('All new organizations are approve by default'), 'none'],
    ]
    value = instance_variable_get("@#{object}").send(method).to_s
    select_tag("#{object}[#{method}]", options_for_select(choices, value))
  end
end
