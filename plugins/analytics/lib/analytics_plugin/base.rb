class AnalyticsPlugin::Base < Noosfero::Plugin

  def body_ending
    return unless profile and profile.analytics_enabled?
    return if @analytics_skip_page_view
    lambda do
      render 'analytics_plugin/body_ending'
    end
  end

  def js_files
    ['analytics'].map{ |j| "javascripts/#{j}" }
  end

  # FIXME: not reloading on development, need server restart
  def application_controller_filters
    [{
      type: 'around_action', options: {}, block: -> &block do
        request_started_at = Time.now
        block.call
        request_finished_at = Time.now

        return if @analytics_skip_page_view
        return unless profile and profile.analytics_enabled?

        Noosfero::Scheduler::Defer.later 'analytics: register page view' do
          page_view = profile.page_views.build request: request, profile_id: profile.id,
            request_started_at: request_started_at, request_finished_at: request_finished_at
          unless profile.analytics_anonymous?
            page_view.user = user
            page_view.session_id = session.id
          end
          page_view.save!
        end
      end,
    }]
  end

  def control_panel_entries
    [AnalyticsPlugin::ControlPanel::AccessTracking]
  end
end
