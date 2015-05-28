module UsersHelper

  FILTER_TRANSLATION = {
      'all_users' => _('All users'),
      'admin_users' => _('Admin users'),
      'activated_users' => _('Activated users'),
      'deactivated_users' => _('Deativated users'),
  }

  def filter_selector(filter, float = 'right')
    options = options_for_select(FILTER_TRANSLATION.map {|key, name| [name, key]}, :selected => filter)
    url_params = url_for(params.merge(:filter => 'FILTER'))
    onchange = "document.location.href = '#{url_params}'.replace('FILTER', this.value)"
    select_field = select_tag(:filter, options, :onchange => onchange)
    content_tag('div',
      content_tag('strong', _('Filter')) + ': ' + select_field,
      :class => "environment-profiles-customize-search"
    )
  end

  def users_filter_title(filter)
    FILTER_TRANSLATION[filter]
  end

end
