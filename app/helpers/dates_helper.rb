module DatesHelper

  include GetText

  # formats a date for displaying.
  def show_date(date)
    if date
      date.strftime(_('%d %B %Y'))
    else
      ''
    end
  end

  # formats a datetime for displaying. 
  def show_time(time)
    if time
      time.strftime(_('%d %B %Y, %H:%m'))
    else
      ''
    end
  end

  def show_period(date1, date2 = nil)
    if (date1 == date2) || (date2.nil?)
      show_date(date1)
    else
      _('from %s to %s') % [show_date(date1), show_date(date2)]
    end
  end

  def show_day_of_week(date)
    # FIXME Date#strftime should translate this for us !!!! 
    _([
      N_('Sunday'),
      N_('Monday'),
      N_('Tuesday'),
      N_('Wednesday'),
      N_('Thursday'),
      N_('Friday'),
      N_('Saturday'),
    ][date.wday])
  end

  def show_month(year, month)
    # FIXME Date#strftime should translate this for us !!! 
    monthname = _([
                  N_('January'),
                  N_('February'),
                  N_('March'),
                  N_('April'),
                  N_('May'),
                  N_('June'),
                  N_('July'),
                  N_('August'),
                  N_('September'),
                  N_('October'),
                  N_('November'),
                  N_('December')
    ][month.to_i - 1])

    _('%{month} %{year}') % { :year => year, :month => monthname }
  end

  def link_to_previous_month(year, month)
    date = (year.blank? || month.blank?) ? Date.today : Date.new(year.to_i, month.to_i, 1)
    previous_month_date = date - 1.month

    link_to '&larr; ' + show_month(previous_month_date.year, previous_month_date.month), :year => previous_month_date.year, :month => previous_month_date.month
  end

  def link_to_next_month(year, month)
    date = (year.blank? || month.blank?) ? Date.today : Date.new(year.to_i, month.to_i, 1)
    next_month_date = date + 1.month

    link_to show_month(next_month_date.year, next_month_date.month) + ' &rarr;', :year => next_month_date.year, :month => next_month_date.month
  end
end
