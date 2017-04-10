module DatesHelper

  include ActionView::Helpers::DateHelper
  def months
    I18n.t('date.month_names')
  end

  def month_name(n, abbreviated = false)
    if abbreviated
      I18n.t('date.abbr_month_names')[n]
    else
      months[n]
    end
  end

  # formats a date for displaying.
  def show_date(date, use_numbers = false, year = true, left_time = false, abbreviated = false)
    if date && abbreviated
      date_format = year ? _('%{month_name} %{year}') : _('%{month_name} %{day}')
      date_format % { :day => date.day, :month_name => month_name(date.month, true), :year => date.year }
    elsif date && use_numbers
      date_format = year ? _('%{month}/%{day}/%{year}') : _('%{month}/%{day}')
      date_format % { :day => date.day, :month => date.month, :year => date.year }
    elsif date && left_time
      date_format = time_ago_in_words(date)
    elsif date
      date_format = year ? _('%{month_name} %{day}, %{year}') : _('%{month_name} %{day}')
      date_format % { :day => date.day, :month_name => month_name(date.month), :year => date.year }
    else
      ''
    end
  end

  def show_date_month(date, use_numbers = false, year=true)
    if date && use_numbers
      date_format = year ? _('%{month}/%{year}') : _('%{month}/%{day}')
      date_format % { :month => date.month, :year => date.year }
    elsif date
      date_format = year ? _('%{month_name}, %{year}') : _('%{month_name}')
      date_format % { :month_name => month_name(date.month), :year => date.year }
    else
      ''
    end
  end

  # formats a datetime for displaying.
  def show_time(time, use_numbers = false, year = true, left_time = false)
    if time && use_numbers
      _('%{month}/%{day}/%{year}, %{hour}:%{minutes}') % { :year => (year ? time.year : ''), :month => time.month, :day => time.day, :hour => time.hour, :minutes => time.strftime("%M") }
    elsif time && left_time
      date_format = time_ago_in_words(time)
    elsif time
      date_format = year ? _('%{month_name} %{day}, %{year} %{hour}:%{minutes}') : _('%{month_name} %{day} %{hour}:%{minutes}')
      date_format % { :day => time.day, :month_name => month_name(time.month), :year => time.year, :hour => time.hour, :minutes => time.strftime("%M") }
    else
      ''
    end
  end

  def show_period(date1, date2 = nil, use_numbers = false)
    if (date1 == date2) || (date2.nil?)
      show_time(date1, use_numbers)
    else
      if date1.year == date2.year
        if date1.month == date2.month
          _('from %{month} %{day1} to %{day2}, %{year}') % {
            :day1 => date1.day,
            :day2 => date2.day,
            :month => use_numbers ? date1.month : month_name(date1.month),
            :year => date1.year
          }
        else
          _('from %{date1} to %{date2}, %{year}') % {
            :date1 => show_date(date1, use_numbers, false),
            :date2 => show_date(date2, use_numbers, false),
            :year => date1.year
          }
        end
      else
        _('from %{date1} to %{date2}') % {
          :date1 => show_time(date1, use_numbers),
          :date2 => show_time(date2, use_numbers)
        }
      end
    end
  end

  def show_day_of_week(date, abbreviated = false)
    # FIXME Date#strftime should translate this for us !!!!
    N_('Sun'); N_('Mon'); N_('Tue'); N_('Wed'); N_('Thu'); N_('Fri'); N_('Sat');
    if abbreviated
      _(date.strftime("%a"))
    else
      # FIXME Date#strftime should translate this for us !!!!
      I18n.t('date.day_names')[date.wday]
    end
  end

  def show_month(year, month, opts = {})
    date = build_date(year, month)
    if opts[:next]
      date = date >> 1
    elsif opts[:previous]
      date = date << 1
    end
    if opts[:only_month]
      _('%{month}') % { :month => month_name(date.month.to_i) }
    else
      _('%{month} %{year}') % { :year => date.year, :month => month_name(date.month.to_i) }
    end
  end

  def build_date(year, month, day = 1)
    if year.blank? and month.blank? and day.blank?
      DateTime.now
    else
      if year.blank?
        year = DateTime.now.year
      end
      if month.blank?
        month = DateTime.now.month
      end
      if day.blank?
        day = 1
      end
      DateTime.new(year.to_i, month.to_i, day.to_i)
    end
  end

  def link_to_previous_month(year, month, label = nil)
    date = build_date(year, month)
    previous_month_date = date - 1.month

    label ||= show_month(previous_month_date.year, previous_month_date.month)
    button(:back, label,  {:year => previous_month_date.year, :month => previous_month_date.month})
  end

  def link_to_next_month(year, month, label = nil)
    date = build_date(year, month)
    next_month_date = date + 1.month

    label ||= show_month(next_month_date.year, next_month_date.month)
    button(:next, label, {:year => next_month_date.year, :month => next_month_date.month})
  end

  def pick_date(object, method, options = {}, html_options = {})
    if language == 'en'
      order = [:month, :day, :year]
    else
      order = [:day, :month, :year]
    end
    date_select(object, method, html_options.merge(options.merge(:include_blank => true, :order => order, :use_month_names => months)))
  end

end
