
class AnalyticsPlugin::Base < Noosfero::Plugin

  def body_ending
    return unless profile and profile.analytics_enabled?
    lambda do
      render 'analytics_plugin/body_ending'
    end
  end

  def js_files
    ['analytics'].map{ |j| "javascripts/#{j}" }
  end

  def application_controller_filters
    [{
      type: 'around_filter', options: {}, block: -> &block do
        request_started_at = Time.now
        block.call
        request_finished_at = Time.now

        return if @analytics_skip_page_view
        return unless profile and profile.analytics_enabled?

        Noosfero::Scheduler::Defer.later 'analytics: register page view' do
          page_view = profile.page_views.build request: request, profile_id: profile,
            request_started_at: request_started_at, request_finished_at: request_finished_at

          unless profile.analytics_anonymous?
            session_id = session.id
            page_view.user = user
            page_view.session_id = session_id
          end

          page_view.save!
        end
      end,
    }]
  end

  def control_panel_buttons
    {
      title: I18n.t('analytics_plugin.lib.plugin.panel_button'),
      icon: 'analytics-access',
      url: {controller: 'analytics_plugin/stats', action: :index}
    }
  end

end
