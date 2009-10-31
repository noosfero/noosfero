class EventsController < PublicController

  needs_profile
  no_design_blocks

  def events
    @selected_day = nil
    @events_of_the_day = []
    date = build_date(params[:year], params[:month], params[:day])

    if params[:day] || !params[:year] && !params[:month]
      @selected_day = date
      @events_of_the_day = profile.events.by_day(@selected_day)
    end

    events = profile.events.by_range(Event.first_day_of_month(date - 1.month)..Event.last_day_of_month(date + 1.month))

    @calendar = populate_calendar(date, events)
    @previous_calendar = populate_calendar(date - 1.month, events)
    @next_calendar = populate_calendar(date + 1.month, events)
  end

  def events_by_day
    @selected_day = build_date(params[:year], params[:month], params[:day])
    @events_of_the_day = profile.events.by_day(@selected_day)
    render :partial => 'events_by_day'
  end

  protected

  include EventsHelper

end
