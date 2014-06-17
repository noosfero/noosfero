class PeopleBlockPlugin < Noosfero::Plugin

  def self.plugin_name
    "People Block Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a people block")
  end

  def self.extra_blocks
    {
      PeopleBlock => {:type => Environment},
      MembersBlock => {:type => Community},
      FriendsBlock => {:type => Person}
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end

end
