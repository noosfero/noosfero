require_dependency 'forms_helper'

module FormsHelper

  protected

  module ResponsiveMethods

    # add -inline class
    def labelled_radio_button( human_name, name, value, checked = false, options = {} )
      return super unless theme_responsive?

      options[:id] ||= 'radio-' + FormsHelper.next_id_number
<<<<<<< HEAD
      content_tag( 'label', radio_button_tag( name, value, checked, options ) + '  ' +
 human_name, for: options[:id], class: 'radio-inline' )
=======
      content_tag :div, class:'radio-inline' do
        content_tag :label, for: options[:id] do
          [
            radio_button_tag(name, value, checked, options),
            ' ',
            human_name,
          ].safe_join
        end
      end
>>>>>>> 2ef3a43... responsive: fix html_safe issues
    end

    # add -inline class
    def labelled_check_box( human_name, name, value = "1", checked = false, options = {} )
      return super unless theme_responsive?

      options[:id] ||= 'checkbox-' + FormsHelper.next_id_number
<<<<<<< HEAD
      hidden_field_tag(name, '0') +
        content_tag( 'label', check_box_tag( name, value, checked, options ) + '  ' + human_name, for: options[:id], class: 'checkbox-inline')
=======
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
>>>>>>> 2ef3a43... responsive: fix html_safe issues
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
<<<<<<< HEAD
=======

      [bt_submit + bt_cancel].safe_join
    end
>>>>>>> 2ef3a43... responsive: fix html_safe issues

      bt_submit + bt_cancel
    end

<<<<<<< HEAD
    %w[select select_tag text_field_tag number_field_tag password_field_tag].each do |method|
      define_method method do |*args, &block|
        #return super(*args, &block) unless theme_responsive?

        options = args.extract_options!
        if options['class']
          options['class'] = "#{options['class']} form-control"
        else
          options[:class] = "#{options[:class]} form-control"
        end
        super(*(args << options), &block)
=======
    %w[
      select_tag
      text_field_tag text_area_tag
      number_field_tag password_field_tag url_field_tag email_field_tag
      month_field_tag date_field_tag
    ].each do |method|
      define_method method do |name, value=nil, options={}, &block|
        responsive_add_field_class! options
        super(name, value, options, &block).html_safe
>>>>>>> 2ef3a43... responsive: fix html_safe issues
      end
    end
    %w[select_month select_year].each do |method|
      define_method method do |date, options={}, html_options={}|
<<<<<<< HEAD
        if html_options['class']
          html_options['class'] = "#{html_options['class']} form-control"
        else
          html_options[:class] = "#{html_options[:class]} form-control"
        end
        super date, options, html_options
=======
        responsive_add_field_class! html_options
        super(date, options, html_options).html_safe
>>>>>>> 2ef3a43... responsive: fix html_safe issues
      end
    end

  end

  include ResponsiveChecks
  prepend ResponsiveMethods

end

