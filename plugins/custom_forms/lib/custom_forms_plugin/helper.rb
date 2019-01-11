module CustomFormsPlugin::Helper
  include ActionView::Helpers::DateHelper

  protected

  def html_for_field(builder, association, klass)
    new_object = klass.new
    builder.fields_for(association, new_object, :child_index => "new_#{association}") do |f|
      render(partial_for_class(klass), :f => f)
    end
  end

  def access_text(form)
    Entitlement::Levels.label(form.access, form.profile)
  end

  def period_range(form)
    if form.beginning.blank? && form.ending.blank?
      _('Always')
    elsif form.beginning.present? && form.ending.blank?
      ('From %s') % time_format(form.beginning)
    elsif form.beginning.blank? && form.ending.present?
      _('Until %s') % time_format(form.ending)
    elsif form.beginning.present? && form.ending.present?
      _('From %s until %s') % [time_format(form.beginning), time_format(form.ending)]
    end
  end

  def time_format(time)
    minutes = (time.min == 0) ? '' : ':%M'
    hour = (time.hour == 0 && minutes.blank?) ? '' : ' %H'
    h = hour.blank? ? '' : 'h'
    time.strftime("%Y-%m-%d#{hour+minutes+h}")
  end

  # TODO add the custom option that should offer the user the hability to
  # choose the profiles one by one, using something like tokeninput
  def access_options(profile)
    associated = profile.organization? ? c_('Members') : c_('Friends')
    [
      [c_('Public'), nil         ],
      [_('Logged users'), 'logged'    ],
      [ associated, 'associated'],
    ]
  end

  def access_result_options
    [
      [_('Always'), 'public'],
      [_('Only after the query ends'), 'public_after_ends'],
      [_('Never'), 'private'],
    ]
  end

  def type_options
    [
      [c_('Text'),   'text_field'  ],
      [_('Select'), 'select_field']
    ]
  end

  def type_to_label(type)
    map = {
      'text_field' => _('Text field'),
      'select_field' => _('Select field')
    }
    map[type_for_options(type)]
  end

  def type_for_options(type)
    type.to_s.split(':').last.underscore
  end

  def display_custom_field(field, submission, form)
    sanitized_name = ActionView::Base.white_list_sanitizer.sanitize field.name
    answer = submission.answers.select{|answer| answer.field == field}.first
    field_tag = send("display_#{type_for_options(field.class)}",field, answer, form).html_safe
    if field.mandatory? && submission.id.nil?
      required(labelled_form_field(sanitized_name, field_tag))
    else
      labelled_form_field(sanitized_name, field_tag)
    end
  end

  def display_disabled?(field, answer)
    (answer.present? && answer.id.present?) || field.form.expired?
  end

  def display_text_field(field, answer, form)
    value = answer.present? ? answer.value : field.default_value
    if field.show_as == 'textarea'
      text_area(form, "#{field.id}", :value => value, :disabled => display_disabled?(field, answer))
    else
      text_field(form, "#{field.id}", :value => value, :disabled => display_disabled?(field, answer))
    end
  end

  def default_selected(field, answer)
    answer.present? ? answer.alternatives.map {|m| m.id.to_s} : field.alternatives.select {|a| a.selected_by_default}.map{|a| a.id.to_s}
  end

  def display_select_field(field, answer, form)
    case field.show_as
    when 'select'
      selected = default_selected(field, answer)
      select_tag form.to_s + "[#{field.id}]",
                 options_for_select([['','']] +
                   field.alternatives.map {|a| [a.label, a.id.to_s]}, selected),
                 :disabled => display_disabled?(field, answer)

    when 'multiple_select'
      selected = default_selected(field, answer)
      input_name = form.to_s + "[#{field.id}]"
      
      inputs = hidden_field_tag(input_name, '0')
      inputs += select_tag input_name, options_for_select(field.alternatives.map{|a| [a.label, a.id.to_s]}, selected),
              :multiple => true, :title => _('Hold down Ctrl to select options'),
              :size => field.alternatives.size,
              :disabled => display_disabled?(field, answer)
      inputs.html_safe

    when 'check_box'
      answers = answer.alternatives.map { |alt| alt.id } if (answer.present?)

      field.alternatives.map do |alternative|
        default = if answer.present?
                    answers.include?(alternative.id)
                  else
                    alternative.selected_by_default
                  end
        content_tag(:div, (labelled_check_box alternative.label,
                           form.to_s + "[#{field.id}][#{alternative.id}]",
                           '1',
                           default,
                           :disabled => display_disabled?(field, answer)),
                    :class => 'labelled-check field-alternative-row')
      end.join("\n")
    when 'radio'
      input_name = form.to_s + "[#{field.id}]"
      inputs = hidden_field_tag(input_name, '0')
      inputs += field.alternatives.map do |alternative|
        default = if answer.present?
                    unless answer.alternatives.empty?
                      answer.alternatives.first.id == alternative.id
                    end
                  else
                    alternative.selected_by_default
                  end

        content_tag(:div, (labelled_radio_button alternative.label,
                           input_name,
                           alternative.id,
                           default,
                           :disabled => display_disabled?(field, answer)),
                           :class => 'labelled-check field-alternative-row')
      end.join("\n").html_safe
    end
  end

  def radio_button?(field)
    type_for_options(field.class) == 'select_field' && field.show_as == 'radio'
  end

  def check_box?(field)
    type_for_options(field.class) == 'select_field' && field.show_as == 'check_box'
  end

  def form_image_header(form)
    content_tag('div', '', class: 'form-image-header', style: "background-image: url(#{form.image_url})")
  end

  def form_image_tag(form)
    image_tag(form.image_url)
  end

  def time_status(form)
    if form.beginning.present? && form.ending.present?
      if Time.now < form.beginning
        _('%s left to open') % distance_of_time_in_words(Time.now, form.beginning)
      elsif Time.now < form.ending
        _('%s left to close') % distance_of_time_in_words(Time.now, form.ending)
      else
        _('Closed')
      end
    elsif form.beginning.present?
      if Time.now < form.beginning
        _('%s left to open') % distance_of_time_in_words(Time.now, form.beginning)
      else
        _('Always open')
      end
    elsif form.ending.present?
      if Time.now < form.ending
        _('%s left to close') % distance_of_time_in_words(Time.now, form.ending)
      else
        _('Closed')
      end
    else
      _("Always open")
    end
  end

end
