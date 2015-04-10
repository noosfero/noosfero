require_dependency 'forms_helper'
require_relative 'application_helper'

module FormsHelper
  extend ActiveSupport::Concern
  protected

  module ResponsiveMethods

    # add -inline class
    def labelled_radio_button( human_name, name, value, checked = false, options = {} )
      return super unless theme_responsive?

      options[:id] ||= 'radio-' + FormsHelper.next_id_number
      content_tag( 'label', radio_button_tag( name, value, checked, options ) + '  ' +
 human_name, for: options[:id], class: 'radio-inline' )
    end

    # add -inline class
    def labelled_check_box( human_name, name, value = "1", checked = false, options = {} )
      return super unless theme_responsive?

      options[:id] ||= 'checkbox-' + FormsHelper.next_id_number
      hidden_field_tag(name, '0') +
        content_tag( 'label', check_box_tag( name, value, checked, options ) + '  ' + human_name, for: options[:id], class: 'checkbox-inline')
    end

    def submit_button(type, label, html_options = {})
      return super unless theme_responsive?

      bt_cancel = html_options[:cancel] ? button(:cancel, _('Cancel'), html_options[:cancel]) : ''

      button_size = html_options[:size] || 'xs'
      size_class = button_size == 'default' ? '' : 'btn-'+button_size
      html_options.delete :size if html_options[:size]

      html_options[:class] = [html_options[:class], 'submit'].compact.join(' ')

      the_class = "btn #{size_class} btn-default with-text icon-#{type}"
      if html_options.has_key?(:class)
        the_class << ' ' << html_options[:class]
      end

      html_options.delete(:cancel)
      bt_submit = button_tag(label, html_options.merge(class: the_class))

      bt_submit + bt_cancel
    end

  end

  include ResponsiveChecks
  included do
    include ResponsiveMethods
  end

  protected
end

module ApplicationHelper

  include FormsHelper::ResponsiveMethods

end

