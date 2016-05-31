require_dependency 'forms_helper'

module FormsHelper

  protected

  module ResponsiveMethods

    # add -inline class
    def labelled_radio_button( human_name, name, value, checked = false, options = {} )
      return super unless theme_responsive?

      options[:id] ||= 'radio-' + FormsHelper.next_id_number
      content_tag :div, class:'radio-inline' do
        content_tag :label, for: options[:id] do
          [
            radio_button_tag(name, value, checked, options),
            ' ',
            human_name,
          ].safe_join
        end
      end
    end

    # add -inline class
    def labelled_check_box( human_name, name, value = "1", checked = false, options = {} )
      return super unless theme_responsive?

      options[:id] ||= 'checkbox-' + FormsHelper.next_id_number
      [
        hidden_field_tag(name, '0'),
        content_tag(:div, class:'checkbox-inline') do
          content_tag :label, for: options[:id] do
            [
              check_box_tag(name, value, checked, options),
              ' ',
              human_name,
            ].safe_join
          end
        end
      ].safe_join
    end

    def submit_button(type, label, html_options = {})
      return super unless theme_responsive?

      bt_cancel = html_options[:cancel] ? button(:cancel, _('Cancel'), html_options[:cancel]) : ''

      button_size = html_options[:size] || 'default'
      size_class = if button_size == 'default' then '' else 'btn-'+button_size end
      html_options.delete :size if html_options[:size]

      html_options[:class] = [html_options[:class], 'submit'].compact.join(' ')

      the_class = "btn #{size_class} btn-default with-text icon-#{type}"
      if html_options.has_key?(:class)
        the_class << ' ' << html_options[:class]
      end

      html_options.delete(:cancel)
      bt_submit = button_tag(label, html_options.merge(class: the_class))

      [bt_submit + bt_cancel].safe_join
    end

      bt_submit + bt_cancel
    end

    %w[
      select_tag
      text_field_tag text_area_tag
      number_field_tag password_field_tag url_field_tag email_field_tag
      month_field_tag date_field_tag
    ].each do |method|
      define_method method do |name, value=nil, options={}, &block|
        responsive_add_field_class! options
        super(name, value, options, &block).html_safe
      end
    end
    %w[select_month select_year].each do |method|
      define_method method do |date, options={}, html_options={}|
        responsive_add_field_class! html_options
        super(date, options, html_options).html_safe
      end
    end

  end

  include ResponsiveChecks
  prepend ResponsiveMethods

end

