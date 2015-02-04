require_dependency File.dirname(__FILE__) + '/profile_members_headlines_block'
require 'ext/person'

class ProfileMembersHeadlinesPlugin < Noosfero::Plugin

  def self.plugin_name
    "Profile Members Headlines Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a block where you can display posts from members.")
  end

  def self.extra_blocks
    { ProfileMembersHeadlinesBlock => { :type => [Community], :position =>
['1'] }}
  end

  def stylesheet?
    true
  end

end
