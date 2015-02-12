class EventPlugin::EventBlock < Block
  include DatesHelper

  attr_accessible :all_env_events, :limit, :future_only, :date_distance_limit

  settings_items :all_env_events, :type => :boolean, :default => false
  settings_items :limit, :type => :integer, :default => 4
  settings_items :future_only, :type => :boolean, :default => true
  settings_items :date_distance_limit, :type => :integer, :default => 0

  def self.description
    _('Events')
  end

  def help
    _('Show the profile events or all environment events.')
  end

  def events_source
    return environment if all_env_events
    if self.owner.kind_of? Environment
      environment.portal_community ? environment.portal_community : environment
    else
      self.owner
    end
  end

  def events(user = nil)
    events = events_source.events
    events = events.published.order('start_date')

    if future_only
      events = events.where('start_date >= ?', Date.today)
    end

    if date_distance_limit > 0
      events = events.by_range([
        Date.today - date_distance_limit,
        Date.today + date_distance_limit
      ])
    end

    event_list = []
    events.each do |event|
      event_list << event if event.display_to? user
      break if event_list.length >= limit
    end

    event_list
  end

  def content(args={})
    block = self
    proc do
      render(
        :file => 'blocks/event',
        :locals => { :block => block }
      )
    end
  end

  def human_time_left(days_left)
    months_left = (days_left/30.0).round
    if days_left <= -60
      n_('One month ago', '%d months ago', -months_left) % -months_left
    elsif days_left < 0
      n_('Yesterday', '%d days ago', -days_left) % -days_left
    elsif days_left == 0
      _("Today")
    elsif days_left < 60
      n_('Tomorrow', '%d days left to start', days_left) % days_left
    else
      n_('One month left to start', '%d months left to start', months_left) % months_left
    end
  end

  def date_to_html(date)
    content_tag(:span, show_day_of_week(date, true), :class => 'week-day') +
    content_tag(:span, month_name(date.month, true), :class => 'month') +
    content_tag(:span, date.day.to_s, :class => 'day') +
    content_tag(:span, date.year.to_s, :class => 'year')
  end

end
