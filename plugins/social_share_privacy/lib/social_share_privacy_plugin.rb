class SocialSharePrivacyPlugin < Noosfero::Plugin

  def self.plugin_name
    "Social Share Privacy"
  end

  def self.plugin_description
    _("A plugin that adds share buttons from other networks.")
  end

  def stylesheet?
    true
  end

  def social_buttons_javascript(article)
    proc do
      javascript_include_tag('plugins/social_share_privacy/javascripts/socialshareprivacy.js') + 
      javascript_include_tag(environment.socialshare.map { |service| "plugins/social_share_privacy/javascripts/modules/#{service}.js" }) + 
      javascript_tag("jQuery.fn.socialSharePrivacy.settings.path_prefix = '../../plugins/social_share_privacy/'; jQuery.fn.socialSharePrivacy.settings.order = #{environment.socialshare}; jQuery(document).ready(function () { jQuery('.social-buttons').socialSharePrivacy({perma_option: false, info_link_target: '_blank'});});") +
      content_tag(:div, '',:class => "social-buttons")
    end
  end

end
