module OrdersPlugin::FieldHelper

  protected

  def labelled_field form, field, label, field_html, options = {}
    help = options.delete(:help)
    content_tag :div,
      if form then form.label field, label, class: 'control-label' else label_tag field, label, class: 'control-label' end +
      content_tag('div', help, class: 'field-help') +
      content_tag('div', field_html, class: 'field-box') +
      content_tag('div', '', style: 'clear: both'),
      options.merge(class: options[:class].to_s + ' field form-group')
  end

  def labelled_radio form, field, label_text, value, options = {}
    content_tag :div,
      form.radio_button(field, value) +
      form.label("#{field}_#{value}", label_text) +
      content_tag('div', '', class: 'clean'),
      options.merge(class: options[:class].to_s + ' field-radio form-group')
  end

end
