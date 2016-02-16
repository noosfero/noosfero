class InviteFriend < Invitation

  settings_items :group_for_person, :group_for_friend
  before_create :check_for_invitation_existence

  def perform
    person.add_friend(friend, group_for_person)
    friend.add_friend(person, group_for_friend)
  end

  def title
    _("Friend invitation")
  end

  def information
    {:message => _('%{requestor} wants to be your friend.')}
  end

  def accept_details
    true
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def target_notification_description
    _('%{requestor} wants to be your friend.') % {:requestor => requestor.name}
  end

  def permission
    :manage_friends
  end

  # Default message send to friend when user use invite a friend feature
  def self.mail_template
    [ _('Hello <friend>,'),
      _('<user> is inviting you to participate on <environment>.'),
      _('To accept the invitation, please follow this link:'),
      '<url>',
      "--\n<environment>",
    ].join("\n\n")
  end

  private
  def check_for_invitation_existence
    if friend
      friend.tasks.pending.of("InviteFriend").where(requestor_id: person.id, target_id: friend.id).blank?
    end
  end

end
