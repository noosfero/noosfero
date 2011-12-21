require_dependency 'ext/profile'

class GoogleAnalyticsPlugin < Noosfero::Plugin

  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::FormHelper
  include ApplicationHelper

  def self.plugin_name
    "Google Analytics"
  end

  def self.plugin_description
    _("Tracking and web analytics to people and communities")
  end

  def profile_id
    context.profile && context.profile.data[:google_analytics_profile_id]
  end

  def head_ending
    unless profile_id.blank?
      expanded_template('tracking-code.rhtml',{:profile_id => profile_id})
    end
  end

  def profile_editor_extras
    labelled_form_field(_('Google Analytics Profile ID'), text_field(:profile_data, :google_analytics_profile_id, :value => context.profile.google_analytics_profile_id))
  end

end
