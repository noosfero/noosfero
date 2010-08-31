class InviteMember < Invitation

  settings_items :community_id, :type => :integer
  validates_presence_of :community_id

  def community
    Community.find(community_id)
  end

  def community=(newcommunity)
    community_id = newcommunity.id
  end

  def perform
    community.add_member(friend)
  end

  def description
    _('%s invited you to join the community %s') % [person.name, community.name]
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

end
