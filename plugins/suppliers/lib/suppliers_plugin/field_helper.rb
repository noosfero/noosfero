module SuppliersPlugin::FieldHelper

  protected

  def labelled_field form, field, label, field_html, options = {}
    help = options.delete(:help)

    field_label = (form ? form.label(field, label) : label_tag(field, label))
    field_help = help.blank? ? '' : content_tag('div', help, class: 'field-help')
    field_box = content_tag('div', field_html, class: 'field-box')

    content_tag('div', field_label + field_help + field_box,
                options.merge(class: options[:class].to_s + ' field'))
  end

end
