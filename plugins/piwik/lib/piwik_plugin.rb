class PiwikPlugin < Noosfero::Plugin

  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def self.plugin_name
    "Piwik"
  end

  def self.plugin_description
    _("Tracking and web analytics to your Noosfero's environment")
  end

  def body_ending
    domain = context.environment.piwik_domain
    site_id = context.environment.piwik_site_id
    unless domain.blank? || site_id.blank?
      expanded_template('tracking-code.rhtml',{:domain => domain, :site_id => site_id})
    end
  end

end
