module EventPlugin::EventBlockHelper
  include DatesHelper

  def date_to_html(date)
    content_tag(:span, show_day_of_week(date, true), :class => 'week-day') +
    content_tag(:span, month_name(date.month, true), :class => 'month') +
    content_tag(:span, date.day.to_s, :class => 'day') +
    content_tag(:span, date.year.to_s, :class => 'year')
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
end
