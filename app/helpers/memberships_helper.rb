module MembershipsHelper

  def join_community_button options={:logged => false}
    url = options[:logged] ? profile.join_url : profile.join_not_logged_url

    if show_confirmation_modal? profile
      modal_link_to font_awesome(:plus, _('Join this community')), url, class: 'join-community'
    elsif !options[:logged]
      modal_link_to font_awesome(:plus, _('Join this community')), url, class: 'join-community'
    else
      link_to font_awesome(:plus, _('Join this community')), url, class: 'join-community'
    end
  end

  def show_confirmation_modal? profile
    profile.requires_email? && current_person && !current_person.public_fields.include?("email")
  end

end
