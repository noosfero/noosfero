module UsersHelper
  def filter_translation
    {
      "all_users" => _("All users"),
      "admin_users" => _("Admin users"),
      "activated_users" => _("Activated users"),
      "deactivated_users" => _("Deativated users"),
      "recently_logged_users" => _("Recently logged users"),
    }
  end

  def filter_selector(filter)
    options = options_for_select(filter_translation.map { |key, name| [name, key] }, selected: filter)
    url_params = url_for(params.merge(filter: "FILTER"))

    onchange = "document.location.href = '#{url_params}'.replace('FILTER', this.value)"

    select_field = select_tag(:filter, options, onchange: onchange)

    content_tag("div",
                content_tag("strong", _("Filter")) + ": " + select_field,
                class: "environment-profiles-customize-search",
                style: "display: inline-flex;")
  end

  def users_filter_title(filter)
    filter_translation[filter]
  end
end
