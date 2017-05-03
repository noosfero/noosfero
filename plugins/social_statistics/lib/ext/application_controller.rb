require_dependency 'application_controller'

ApplicationController.class_eval do
  def social_statistics_plugin_verify_access
    if user.blank? || user.environment.blank? || !user.environment.plugin_enabled?('SocialStatisticsPlugin')
      social_statistics_plugin_not_found
    elsif !user.is_admin?
      social_statistics_plugin_access_denied
    end
  end

  private

  def social_statistics_plugin_not_found
    @no_design_blocks = true
    @path ||= request.path
    render template: 'shared/not_found', status: 404
  end

  def social_statistics_plugin_access_denied
    @no_design_blocks = true
    render template: 'shared/access_denied', status: 403
  end
end
