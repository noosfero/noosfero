class InviteMember < Invitation

  settings_items :community_id, :type => :integer
  validates_presence_of :community_id
  before_create :check_for_invitation_existence

  def community
    Community.find(community_id)
  end

  def community=(newcommunity)
    community_id = newcommunity.id
  end

  def perform
    community.add_member(friend)
  end

  def title
    _("Community invitation")
  end

  def linked_subject
    {:text => community.name, :url => community.public_profile_url}
  end

  def information
    {:message => _('%{requestor} invited you to join %{linked_subject}.')}
  end

  def url
    community.url
  end

  def icon
    {:type => :profile_image, :profile => community, :url => community.url}
  end

  def target_notification_description
    _('%{requestor} invited you to join %{community}.') % {:requestor => requestor.name, :community => community.name}
  end

  def target_notification_message
    if friend
      _('%{requestor} is inviting you to join "%{community}" on %{system}.') % { :system => target.environment.name, :requestor => requestor.name, :community => community.name }
    else
      super
    end
  end

  def expanded_message
    super.gsub /<community>/, community.name
  end

  # Default message send to friend when user use invite a friend feature
  def self.mail_template
    [ _('Hello <friend>,'),
      _('<user> is inviting you to join "<community>" on <environment>.'),
      _('To accept the invitation, please follow this link:'),
      '<url>',
      "--\n<environment>",
    ].join("\n\n")
  end

  private
  def check_for_invitation_existence
    if friend
      friend.tasks.pending.of("InviteMember").find(:all, :conditions => {:requestor_id => person.id}).select { |t| t.data[:community_id] == community_id }.blank?
    end
  end

end
