module ProfileHelper

  def display_field(title, profile, field, force = false)
    unless force || profile.may_display_field_to?(field, user)
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
    fields = []
    fields << display_field(_('Address:'), profile, :address).html_safe
    fields << display_field(_('ZIP code:'), profile, :zip_code).html_safe
    fields << display_field(_('Contact phone:'), profile, :contact_phone).html_safe
    fields << display_field(_('e-Mail:'), profile, :email) { |email| link_to_email(email) }.html_safe
    fields << display_field(_('Personal website:'), profile, :personal_website).html_safe
    fields << display_field(_('Jabber:'), profile, :jabber_id).html_safe
    if fields.reject!(&:blank?).empty?
      ''
    else
      content_tag('tr', content_tag('th', _('Contact'), { :colspan => 2 })) + fields.join.html_safe
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
