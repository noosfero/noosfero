module EventBlockHelper
  include DatesHelper

  def date_to_html(date)
    content_tag(:span, show_day_of_week(date, true), :class => 'week-day') +
    content_tag(:span, month_name(date.month, true), :class => 'month') +
    content_tag(:span, date.day.to_s, :class => 'day') +
    content_tag(:span, date.year.to_s, :class => 'year')
  end
end
