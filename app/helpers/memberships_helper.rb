module MembershipsHelper

  def join_community_button options={:logged => false}
    url = options[:logged] ? profile.join_url : profile.join_not_logged_url

    if show_confirmation_modal? profile
      modal_button :add, _('Join this community'), url, class: 'join-community'
    else
      button :add, _('Join this community'), url, class: 'join-community'
    end
  end

  def show_confirmation_modal? profile
    profile.requires_email? && current_person && !current_person.public_fields.include?("email")
  end

end
