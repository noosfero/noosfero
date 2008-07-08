module DatesHelper

  include GetText

  MONTHS = [
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
  ]

  def month_name(n)
    _(MONTHS[n-1])
  end

  # formats a date for displaying.
  def show_date(date)
    if date
      _('%{month} %{day}, %{year}') % { :day => date.day, :month => month_name(date.month), :year => date.year }
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

    if year.blank?
      year = Date.today.year
    end
    if month.blank?
      month = Date.today.month
    end

    _('%{month} %{year}') % { :year => year, :month => month_name(month.to_i) }
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

  def pick_date(object, method)
    date_select(object, method, :use_month_names => MONTHS.map {|item| gettext(item)})
  end

end
