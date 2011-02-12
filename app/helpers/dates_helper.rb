require 'noosfero/i18n'

module DatesHelper

  # FIXME Date#strftime should translate this for us !!!!
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
  def show_date(date, use_numbers = false)
    if date && use_numbers
      _('%{month}/%{day}/%{year}') % { :day => date.day, :month => date.month, :year => date.year }
    elsif date
      _('%{month} %{day}, %{year}') % { :day => date.day, :month => month_name(date.month), :year => date.year }
    else
      ''
    end
  end

  # formats a datetime for displaying. 
  def show_time(time)
    if time
      _('%{day} %{month} %{year}, %{hour}:%{minutes}') % { :year => time.year, :month => month_name(time.month), :day => time.day, :hour => time.hour, :minutes => time.strftime("%M") }
    else
      ''
    end
  end

  def show_period(date1, date2 = nil)
    if (date1 == date2) || (date2.nil?)
      show_date(date1)
    else
      _('from %{date1} to %{date2}') % {:date1 => show_date(date1), :date2 => show_date(date2)}
    end
  end

  def show_day_of_week(date, abbreviated = false)
    # FIXME Date#strftime should translate this for us !!!!
    N_('Sun'); N_('Mon'); N_('Tue'); N_('Wed'); N_('Thu'); N_('Fri'); N_('Sat');
    if abbreviated
      _(date.strftime("%a"))
    else
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
  end

  def show_month(year, month, opts = {})
    date = build_date(year, month)
    if opts[:next]
      date = date >> 1
    elsif opts[:previous]
      date = date << 1
    end
    _('%{month} %{year}') % { :year => date.year, :month => month_name(date.month.to_i) }
  end

  def build_date(year, month, day = 1)
    if year.blank? and month.blank? and day.blank?
      Date.today
    else
      if year.blank?
        year = Date.today.year
      end
      if month.blank?
        month = Date.today.month
      end
      if day.blank?
        day = 1
      end
      Date.new(year.to_i, month.to_i, day.to_i)
    end
  end

  def link_to_previous_month(year, month, label = nil)
    date = build_date(year, month)
    previous_month_date = date - 1.month

    label ||= show_month(previous_month_date.year, previous_month_date.month)
    link_to label, :year => previous_month_date.year, :month => previous_month_date.month
  end

  def link_to_next_month(year, month, label = nil)
    date = build_date(year, month)
    next_month_date = date + 1.month

    label ||= show_month(next_month_date.year, next_month_date.month)
    link_to label, :year => next_month_date.year, :month => next_month_date.month
  end

  def pick_date(object, method, options = {}, html_options = {})
    if language == 'en'
      order = [:month, :day, :year]
    else
      order = [:day, :month, :year]
    end
    date_select(object, method, html_options.merge(options.merge(:include_blank => true, :order => order, :use_month_names => MONTHS.map {|item| gettext(item)})))
  end

end
