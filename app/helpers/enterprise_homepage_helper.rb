module EnterpriseHomepageHelper

  def display_profile_info(profile)
    data = ''
    unless profile.contact_person.blank?
      data << content_tag('strong', _('Contact person: ')) + profile.contact_person + '<br/>'
    end
    unless profile.contact_email.blank?
      data << content_tag('strong', _('E-Mail: ')) + profile.contact_email + '<br/>'
    end
    unless profile.contact_phone.blank?
      data << content_tag('strong', _('Phone(s): ')) + profile.contact_phone + '<br/>'
    end
    unless profile.region.nil?
      data << content_tag('strong', _('Location: ')) + profile.region.name + '<br/>'
    end
    unless profile.address.blank?
      data << content_tag('strong', _('Address: ')) + profile.address + '<br/>'
    end
    unless profile.legal_form.blank?
      data << content_tag('strong', _('Legal form: ')) + profile.legal_form + '<br/>'
    end
    unless profile.foundation_year.blank?
      data << content_tag('strong', _('Foundation year: ')) + profile.foundation_year + '<br/>'
    end
    unless profile.economic_activity.blank?
      data << content_tag('strong', _('Economic activity: ')) + profile.economic_activity + '<br/>'
    end
    if profile.respond_to?(:distance) and !profile.distance.nil?
      data << content_tag('strong', _('Distance: ')) + "%.2f%" % profile.distance + '<br/>'
    end
    content_tag('div', data, :class => 'profile-info')
  end

end
