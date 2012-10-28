module ProfileHelper

  def display_field(title, profile, field, force = false)
    if (!force && field.to_s != 'email' && !profile.active_fields.include?(field.to_s)) ||
       ((profile.active_fields.include?(field.to_s) || field.to_s == 'email') && !profile.public_fields.include?(field.to_s) && (!user || (user != profile && !user.is_a_friend?(profile))))
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
