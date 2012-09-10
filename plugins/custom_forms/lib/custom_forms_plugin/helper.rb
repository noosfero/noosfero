module CustomFormsPlugin::Helper
  def access_text(form)
    return _('Public') if form.access.nil?
    return _('Logged users') if form.access == 'logged'
    if form.access == 'associated'
      return _('Members') if form.profile.organization? 
      return _('Friends') if form.profile.person?
    end
    return _('Custom')
  end

  def period_range(form)
    if form.begining.blank? && form.ending.blank?
      _('Always')
    elsif form.begining.present? && form.ending.blank?
      ('From %s') % time_format(form.begining)
    elsif form.begining.blank? && form.ending.present?
      _('Until %s') % time_format(form.ending)
    elsif form.begining.present? && form.ending.present?
      _('From %s until %s') % [time_format(form.begining), time_format(form.ending)]
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
    associated = profile.organization? ? _('Members') : _('Friends')
    [
      [_('Public'), nil         ],
      [_('Logged users'), 'logged'    ],
      [ associated, 'associated'],
    ]
  end

  def type_options
    [
      [_('Text'),   'text_field'  ],
      [_('Select'), 'select_field']
    ]
  end

  def type_to_label(type)
    map = {
      'text_field' => _('Text'),
      'select_field' => _('Select')
    }
    map[type_for_options(type)]
  end

  def type_for_options(type)
    type.to_s.split(':').last.underscore
  end

  def display_custom_field(field, submission, form)
    answer = submission.answers.select{|answer| answer.field == field}.first
    field_tag = send("display_#{type_for_options(field.class)}",field, answer, form)
    if field.mandatory? && !radio_button?(field) && !check_box?(field) && submission.id.nil?
      required(labelled_form_field(field.name, field_tag))
    else 
      labelled_form_field(field.name, field_tag)
    end
  end

  def display_text_field(field, answer, form)
    value = answer.present? ? answer.value : field.default_value
    text_field(form, field.name.to_slug, :value => value, :disabled => answer.present?)
  end

  def display_select_field(field, answer, form)
    if field.list && field.multiple
      selected = answer.present? ? answer.value.split(',') : []
      select_tag "#{form}[#{field.name.to_slug}]", options_for_select(field.choices.to_a, selected), :multiple => true, :size => field.choices.size, :disabled => answer.present?
    elsif !field.list && field.multiple
      field.choices.map do |name, value|
        default = answer.present? ? answer.value.split(',').include?(value) : false
        labelled_check_box name, "#{form}[#{field.name.to_slug}][#{value}]", '1', default, :disabled => answer.present?
      end.join("\n")
    elsif field.list && !field.multiple
      selected = answer.present? ? answer.value.split(',') : []
      select_tag "#{form}[#{field.name.to_slug}]", options_for_select([['','']] + field.choices.to_a, selected), :disabled => answer.present?
    elsif !field.list && !field.multiple
      field.choices.map do |name, value|
        default = answer.present? ? answer.value == value : true
        labelled_radio_button name, "#{form}[#{field.name.to_slug}]", value, default, :disabled => answer.present?
      end.join("\n")
    end
  end

  def radio_button?(field)
    type_for_options(field.class) == 'select_field' && !field.list && !field.multiple
  end

  def check_box?(field)
    type_for_options(field.class) == 'select_field' && !field.list && field.multiple
  end

  def build_answers(submission, form)
    answers = []
    submission.each do |slug, value|
      field = form.fields.select {|field| field.slug==slug}.first
      if value.kind_of?(String)
        final_value = value
      elsif value.kind_of?(Array)
        final_value = value.join(',')
      elsif value.kind_of?(Hash)
        final_value = value.map {|option, present| present == '1' ? option : nil}.compact.join(',')
      end
      answers << CustomFormsPlugin::Answer.new(:field => field, :value => final_value)
    end
    answers
  end
end
