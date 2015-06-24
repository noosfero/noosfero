class SocialSharePrivacyPlugin < Noosfero::Plugin

  def self.plugin_name
    "Social Share Privacy"
  end

  def self.plugin_description
    _("A plugin that adds share buttons from other networks.")
  end

  def self.networks_default_setting
    []
  end

  def stylesheet?
    true
  end

  def article_extra_contents(article)
    proc do
      settings = Noosfero::Plugin::Settings.new(environment, SocialSharePrivacyPlugin)
      modules = settings.get_setting(:networks).map { |service| "/plugins/social_share_privacy/socialshareprivacy/javascripts/modules/#{service}.js" }
      locale = FastGettext.locale
      javascript_include_tag('/plugins/social_share_privacy/socialshareprivacy/javascripts/socialshareprivacy.js') +
      javascript_include_tag('/plugins/social_share_privacy/socialshareprivacy/javascripts/localstorage.js') +
      (modules.present? ? javascript_include_tag(*modules) : '') +
      javascript_include_tag("/plugins/social_share_privacy/socialshareprivacy/javascripts/modules/facebook.js") +
      (locale != 'en' ? javascript_include_tag("/plugins/social_share_privacy/socialshareprivacy/javascripts/locale/jquery.socialshareprivacy.min.#{locale}.js") : '') +
      javascript_tag("jQuery.fn.socialSharePrivacy.settings.path_prefix = '/plugins/social_share_privacy/socialshareprivacy/'; jQuery.fn.socialSharePrivacy.settings.order = #{settings.get_setting(:networks)}; jQuery(document).ready(function () { jQuery('.social-buttons').socialSharePrivacy({info_link_target: '_blank'});});") +
      content_tag(:div, '', :class => "social-buttons")
    end
  end

end
