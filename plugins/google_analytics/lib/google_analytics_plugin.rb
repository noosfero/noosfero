class GoogleAnalyticsPlugin < Noosfero::Plugin

  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def self.plugin_name
    "Google Analytics"
  end

  def self.plugin_description
    _("Tracking and web analytics to people and communities")
  end

  def profile_id
    context.profile && context.profile.google_analytics_profile_id
  end

  def head_ending
    unless profile_id.blank?
      expanded_template('tracking-code.html.erb',{:profile_id => profile_id})
    end
  end

  def profile_editor_extras
    analytics_id = profile_id
    lambda {
      render :file => 'profile-editor-extras', :locals => { :profile_id => analytics_id }
    }
  end

end
