class EventsController < PublicController

  needs_profile

  def events
    @events = []
    @date = build_date(params[:year], params[:month], params[:day])

    if !params[:year] && !params[:month] && !params[:day]
      @events = profile.events.next_events_from_month(@date)
    end

    if params[:year] || params[:month]
      @events = profile.events.by_month(@date)
    end

    events_in_range = profile.events.by_range((@date - 1.month).at_beginning_of_month .. (@date + 1.month).at_end_of_month)

    @calendar = populate_calendar(@date, events_in_range)
  end

  def events_by_day
    @date = build_date(params[:year], params[:month], params[:day])
    @events = profile.events.by_day(@date)
    render :partial => 'events'
  end

  protected

  include EventsHelper

end
