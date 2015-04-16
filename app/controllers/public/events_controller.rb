class EventsController < PublicController

  needs_profile
  before_filter :allow_access_to_page

  def events
    @events = []
    begin
      @date = build_date params[:year], params[:month], params[:day]
    rescue ArgumentError # invalid date
      return render_not_found
    end

    if !params[:year] && !params[:month] && !params[:day]
      @events = profile.events.next_events_from_month(@date).paginate(:per_page => per_page, :page => params[:page])
    end

    if params[:year] || params[:month]
      @events = profile.events.by_month(@date).paginate(:per_page => per_page, :page => params[:page])
    end

    events_in_range = profile.events.by_range((@date - 1.month).at_beginning_of_month .. (@date + 1.month).at_end_of_month)

    @calendar = populate_calendar(@date, events_in_range)
  end

  def events_by_day
    @date = build_date(params[:year], params[:month], params[:day])
    @events = profile.events.by_day(@date).paginate(:per_page => per_page, :page => params[:page])
    render :partial => 'events'
  end

  protected

  include EventsHelper

  def per_page
    20
  end
end
