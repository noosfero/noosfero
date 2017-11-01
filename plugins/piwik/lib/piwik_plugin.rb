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

  def stylesheet?
    true
  end

  def body_ending
    domain = context.environment.piwik_domain
    site_id = context.environment.piwik_site_id
    unless domain.blank? || site_id.blank?
      piwik_url = "#{domain}/#{context.environment.piwik_path}"
      piwik_url = "#{piwik_url}/" unless piwik_url.end_with?('/')
      expanded_template('tracking-code.html.erb', {:site_id => site_id, :piwik_url => piwik_url})
    end
  end

  def user_menu_items(user)
    domain = context.environment.piwik_domain
    if user.is_admin? && domain.present?
      path = context.environment.piwik_path
      id_site = context.environment.piwik_site_id
      proc do
        protocol = request.ssl? ? 'https' : 'http'
        link_to "#{protocol}://#{domain}/#{path}?idSite=#{id_site}" do
          content_tag('i', nil, class: 'icon-piwik') +
          content_tag('strong', _('Piwik'))
        end
      end
    end
  end

end
