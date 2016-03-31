module CustomFieldsHelper

  def format_name(format)
    names = {}
    names['string'] = _('String')
    names['text'] = _('Text')
    names['date'] = _('Date')
    names['numeric'] = _('Numeric')
    names['link'] = _('Link')
    names['list'] = _('List')
    names['checkbox'] = _('Checkbox')
    names[format]
  end

  def custom_field_forms(customized_type)
    forms = []
    forms << [_('String'), form_for_format(customized_type,'string')]
    forms << [_('Text'), form_for_format(customized_type,'text')]
    forms << [_('Date'), form_for_format(customized_type,'date')]
    forms << [_('Numeric'), form_for_format(customized_type,'numeric')]
    forms << [_('Link'), form_for_format(customized_type,'link')]
    forms << [_('List'), form_for_format(customized_type,'list')]
    forms << [_('Checkbox'), form_for_format(customized_type,'checkbox')]
    forms
  end

  def render_extras_field(id, extra=nil, field=nil)
    if extra.nil?
      CGI::escapeHTML((render(:partial => 'features/custom_fields/extras_field', :locals => {:id => id, :extra => nil, :field => field})))
    else
      render :partial => 'features/custom_fields/extras_field', :locals => {:id => id, :extra => extra, :field => field}
    end
  end

  def form_for_field(field, customized_type)
    render :partial => 'features/custom_fields/form', :locals => {:field => field}
  end

  def display_custom_field_value(custom_field_value)
    value_for_format custom_field_value.custom_field.format, custom_field_value.value
  end

  def display_value_for_custom_field(custom_field, value)
    value_for_format custom_field.format, value
  end

  def value_for_format format, value
    case format
    when 'text', 'list', 'numeric', 'date', 'string'
      value
    when 'checkbox'
      value == "1" ? _('Yes') : _('No')
    when 'link'
      url = value[/\Ahttps?:\/\//i] ? value : "http://#{value}"
      link_to(value, url, :target => '_blank')
    end

  end

  private

  def form_for_format(customized_type, format)
    field = CustomField.new(:format => format, :customized_type => customized_type, :environment => environment)
    CGI::escapeHTML((render(:partial => 'features/custom_fields/form', :locals => {:field => field})))
  end
end
