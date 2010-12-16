module ProfileHelper

  def display_field(title, profile, field, force = false)
    if !force && !profile.active_fields.include?(field.to_s)
      return ''
    end
    value = profile.send(field)
    if !value.blank?
      if block_given?
        value = yield(value)
      end
      content_tag('tr', content_tag('td', title, :class => 'field-name') + content_tag('td', value))
    else
      ''
    end
  end

  def render_tabs(tabs)
    titles = tabs.inject(''){ |result, tab| result << content_tag(:li, link_to(tab[:title], '#'+tab[:id]), :class => 'tab') }
    contents = tabs.inject(''){ |result, tab| result << content_tag(:div, tab[:content], :id => tab[:id]) }

    content_tag :div, :class => 'ui-tabs' do
      content_tag(:ul, titles) + contents
    end
  end
end
