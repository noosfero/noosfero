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

end
