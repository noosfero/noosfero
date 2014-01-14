require_dependency File.dirname(__FILE__) + '/community_block'

class CommunityBlockPlugin < Noosfero::Plugin

  def self.plugin_name
    "Community Block Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a block to show community description")
  end

  def self.extra_blocks
    {
      CommunityBlock => {:type => Community}
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end

end
