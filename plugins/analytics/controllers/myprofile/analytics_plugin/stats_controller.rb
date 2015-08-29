class AnalyticsPlugin::StatsController < MyProfileController

  no_design_blocks

  before_filter :skip_page_view

  def index
  end

  protected

  def default_url_options
    # avoid rails' use_relative_controller!
    {use_route: '/'}
  end

  def skip_page_view
    @analytics_skip_page_view = true
  end

end
