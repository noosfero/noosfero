class AnalyticsPlugin::TimeOnPageController < ProfileController

  before_filter :skip_page_view

  def page_load
    # to avoid concurrency problems with the original deferred request, also defer this
    Noosfero::Scheduler::Defer.later do
      page_view = profile.page_views.where(request_id: params[:id]).first
      page_view.request = request
      AnalyticsPlugin::PageView.transaction do
        page_view.page_load! Time.at(params[:time].to_i)
        page_view.update_column :title, params[:title] if params[:title].present?
      end
    end

    render nothing: true
  end

  def report
    page_view = profile.page_views.where(request_id: params[:id]).first
    page_view.request = request
    page_view.increase_time_on_page!

    render nothing: true
  end

  protected

  def skip_page_view
    @analytics_skip_page_view = true
  end

end
