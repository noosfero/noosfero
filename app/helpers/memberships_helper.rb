module MembershipsHelper

  def join_community_button(logged)
    url = logged ? profile.join_url : profile.join_not_logged_url

    if profile.requires_email? && current_person && !current_person.public_fields.include?("email")
      modal_button :add, _('Join this community'), url, class: 'join-community'
    else
      button :add, _('Join this community'), url, class: 'join-community'
    end
  end
end
