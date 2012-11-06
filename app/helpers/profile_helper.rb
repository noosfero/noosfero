module ProfileHelper

  def display_field(title, profile, field, force = false)
    if (!force && !profile.active_fields.include?(field.to_s)) ||
       (profile.active_fields.include?(field.to_s) && !profile.public_fields.include?(field.to_s) && (!user || (user != profile && !user.is_a_friend?(profile))))
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

  def display_contact(profile)
    address = display_field(_('Address:'), profile, :address)
    zip = display_field(_('ZIP code:'), profile, :zip_code)
    phone = display_field(_('Contact phone:'), profile, :contact_phone)
    email = display_field(_('e-Mail:'), profile, :email) { |email| link_to_email(email) }
    if address.blank? && zip.blank? && phone.blank? && email.blank?
      ''
    else
      content_tag('tr', content_tag('th', _('Contact'), { :colspan => 2 })) + address + zip + phone + email
    end
  end

  def display_work_info(profile)
    organization = display_field(_('Organization:'), profile, :organization)
    organization_site = display_field(_('Organization website:'), profile, :organization_website) { |url| link_to(url, url) }
    if organization.blank? && organization_site.blank?
      ''
    else
      content_tag('tr', content_tag('th', _('Work'), { :colspan => 2 })) + organization + organization_site
    end
  end

end
