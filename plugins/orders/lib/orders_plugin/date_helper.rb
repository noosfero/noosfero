module OrdersPlugin::DateHelper

  protected

  include OrdersPlugin::FieldHelper

  def date_range_field form, start_field, end_field, options = {}
    start_time = form.object.send(start_field) || Time.now
    end_time = form.object.send(end_field) || Time.now+1.week

    render 'orders_plugin/shared/daterangepicker/form_field', form: form, options: options,
      start_field: start_field, end_field: end_field, start_time: start_time, end_time: end_time
  end

  def datetime_range_field form, start_field, end_field, options = {}
    date_range_field form, start_field, end_field, timePicker: true, timePickerIncrement: 15, timePicker12Hour: false
  end

  def labelled_datetime_range_field form, start_field, end_field, label, options = {}
    labelled_field form, label, label, datetime_range_field(form, start_field, end_field, options)
  end

  def datetime_period_with_from start, finish
    I18n.t('orders_plugin.lib.date_helper.from_start_to_finish') % {
     start: start.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_hh_m')),
     finish: finish.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_hh_m')),
    }
  end

  def day_time time
    time.strftime I18n.t('orders_plugin.lib.date_helper.b_d_at_hh_m')
  end

  def day_time_period start, finish
    start.strftime I18n.t('orders_plugin.lib.date_helper.b_d_from_time_start_t') % {
      default_format: start.strftime(I18n.t 'date.formats.default'),
      time_start: start.strftime(I18n.t 'orders_plugin.lib.date_helper.hh_m'),
      time_finish: finish.strftime(I18n.t 'orders_plugin.lib.date_helper.hh_m'),
    }
  end

  def day_time_short time
    time.strftime time.min > 0 ? I18n.t('orders_plugin.lib.date_helper.m_d_hh_m') : I18n.t('orders_plugin.lib.date_helper.m_d_hh')
  end

  def datetime_period_with_day start, finish
    (start.to_date == finish.to_date ?
      I18n.t('orders_plugin.lib.date_helper.start_day_from_start_') :
      I18n.t('orders_plugin.lib.date_helper.start_day_start_datet')
    ) % {
      start_day: I18n.l(start, format: I18n.t('orders_plugin.lib.date_helper.a')).downcase,
      start_datetime: start.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_hh_m')),
      start_time: start.strftime(I18n.t('orders_plugin.lib.date_helper.hh_m')),
      finish_day: I18n.l(finish, format: I18n.t('orders_plugin.lib.date_helper.a')).downcase,
      finish_datetime: finish.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_hh_m')),
      finish_time: finish.strftime(I18n.t('orders_plugin.lib.date_helper.hh_m')),
    }
  end

  def datetime_period_short start, finish
    I18n.t('orders_plugin.lib.date_helper.start_finish') % {
      start: day_time_short(start),
      finish: day_time_short(finish)
    }
  end

  def datetime_full time
    time.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_at_hh_m'))
  end

  def month_with_time time
    time.strftime(I18n.t('orders_plugin.lib.date_helper.m_y_hh_m'))
  end

end
