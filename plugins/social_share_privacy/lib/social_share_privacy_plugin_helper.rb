module SocialSharePrivacyPluginHelper

  def social_share_privacy_networks
    Dir[SocialSharePrivacyPlugin.root_path + 'public/socialshareprivacy/javascripts/modules/*.js'].map { |entry| entry.split('/').last.gsub(/\.js$/,'') }
  end

end
