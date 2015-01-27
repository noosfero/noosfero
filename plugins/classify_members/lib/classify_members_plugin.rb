class ClassifyMembersPlugin < Noosfero::Plugin
  def self.plugin_name
    _("Classify Members")
  end

  def self.plugin_description
    _("Allows the association of communities with types of user profiles to classify and highlight them within the environment.")
  end

  def html_tag_classes
    plugin = self
    lambda do
      if profile && profile.person?
        plugin.find_community(profile).map do |community, community_label|
          'member-of-' + community.identifier
        end
      end
    end
  end

  def body_beginning
    plugin = self
    lambda do
      if profile && profile.person?
        javascript_tag("
          jQuery(function(){
            jQuery('<div class=\"cmm-member-tags\"><ul class=\"cmm-member-list\"></ul></div>').insertBefore(
              '.profile-image-block .vcard .profile-info-options'
            );
          });\n" +
          plugin.find_community(profile).map do |community, community_label|
          "jQuery(function(){
            jQuery('.cmm-member-list').prepend(
              '<li>' + '#{link_to '<i></i>' + community_label,
                {:profile => community.identifier, :controller => 'profile', :action => 'members'},
                :class => 'member-of-' + community.identifier}' + '</li>'
            );
          });"
          end.join("\n")
        )
      else
        '<!-- ClassCommunityPlugin not in a profile -->'
      end
    end
  end

  def settings
    @settings ||= Noosfero::Plugin::Settings.new(
      context.environment, ClassifyMembersPlugin
    )
  end

  def communities
    communities = settings.communities

    return [] if communities.blank?

    communities.split(/\s*\n\s*/).map do |community|
      community = community.split(/\s*:\s*/)
      community[0] = Profile[community[0].to_s.strip]
      community[1] = community[1].to_s.strip

      if community[0].blank?
        nil
      else
        community[1] = community[0].name if community[1].blank?
        community
      end
    end.compact
  end

  def find_community(profile)
    communities.map do |community|
      profile.is_member_of?(community[0]) ? community : nil
    end.compact
  end

end
