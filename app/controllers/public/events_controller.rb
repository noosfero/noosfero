class EventsController < PublicController

  needs_profile
  before_action :allow_access_to_page
  before_action :load_events

  def events
    events_in_range = profile.events.accessible_to(user).by_range((@date - 1.month).at_beginning_of_month .. (@date + 1.month).at_end_of_month)
    @calendar = populate_calendar(@date, events_in_range)
    @events = @events.paginate(:per_page => per_page, :page => params[:page])
  end

  def events_by_date
    @events = @events.paginate(:per_page => per_page, :page => params[:page])
    render :partial => 'events', locals: { xhr_links: true }
  end

  protected

  include EventsHelper

  def per_page
    20
  end

  def load_events
    begin
      @date = build_date params[:year], params[:month], params[:day]
    rescue ArgumentError # invalid date
      return render_not_found
    end

    @events = profile.events.accessible_to(user)

    if params[:year] && params[:month] && params[:day]
      @events = @events.by_day(@date)
    else
      @events = @events.by_month(@date)
    end
  end
end
