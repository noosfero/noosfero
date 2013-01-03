module FormsHelper

  def generate_form( name, obj, fields={} )
    labelled_form_for name, obj do |f|
      f.text_field(:name)
    end
  end

  def labelled_radio_button( human_name, name, value, checked = false, options = {} )
    options[:id] ||= 'radio-' + FormsHelper.next_id_number
    radio_button_tag( name, value, checked, options ) +
    content_tag( 'label', human_name, :for => options[:id] )
  end

  def labelled_check_box( human_name, name, value = "1", checked = false, options = {} )
    options[:id] ||= 'checkbox-' + FormsHelper.next_id_number
    hidden_field_tag(name, '0') +
      check_box_tag( name, value, checked, options ) +
      content_tag( 'label', human_name, :for => options[:id] )
  end

  def labelled_text_field( human_name, name, value=nil, options={} )
    options[:id] ||= 'text-field-' + FormsHelper.next_id_number
    content_tag('label', human_name, :for => options[:id]) +
    text_field_tag( name, value, options )
  end

  def labelled_select( human_name, name, value_method, text_method, selected, collection, options={} )
    options[:id] ||= 'select-' + FormsHelper.next_id_number
    content_tag('label', human_name, :for => options[:id]) +
    select_tag( name, options_from_collection_for_select(collection, value_method, text_method, selected), options)
  end

  def submit_button(type, label, html_options = {})
    bt_cancel = html_options[:cancel] ? button(:cancel, _('Cancel'), html_options[:cancel]) : ''

    html_options[:class] = [html_options[:class], 'submit'].compact.join(' ')

    the_class = "button with-text icon-#{type}"
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end

    bt_submit = submit_tag(label, html_options.merge(:class => the_class))

    bt_submit + bt_cancel
  end

  def text_field_with_local_autocomplete(name, choices, html_options = {})
    id = html_options[:id] || name

    text_field_tag(name, '', html_options) +
    content_tag('div', '', :id => "autocomplete-for-#{id}", :class => 'auto-complete', :style => 'display: none;') +
    javascript_tag('new Autocompleter.Local(%s, %s, %s)' % [ id.to_json, "autocomplete-for-#{id}".to_json, choices.to_json ] )
  end

  def select_city( simple=false )
    states = State.find(:all, :order => 'name')
    
    state_id = 'state-' + FormsHelper.next_id_number
    city_id = 'city-' + FormsHelper.next_id_number

    if states.length < 1
      return
    end
    
    if simple
      states = [State.new(:name => _('Select the State'))] + states
      cities = [City.new(:name => _('Select the City'))]

      html_state =
      content_tag( 'div',
                   select_tag( 'state',
                               options_from_collection_for_select( states, :id, :name, nil),
                               :id => state_id ),
                   :class => 'select_state_for_origin' )
      html_city =
      content_tag( 'div',
                   select_tag( 'city',
                               options_from_collection_for_select( cities, :id, :name, nil),
                               :id => city_id ),
                   :class => 'select_city_for_origin' )
      html_state['<option'] = '<option class="first-option"'
      html_city['<option']  = '<option class="first-option"'
      html = html_state + html_city
    else
      states = [State.new(:name => '---')] + states
      cities = [City.new(:name => '---')]

      html = 
      content_tag( 'div',
                   labelled_select( _('State:'), 'state', :id, :name, nil, states, :id => state_id ),
                   :class => 'select_state_for_origin' ) +
      content_tag( 'div',
                   labelled_select( _('City:'), 'city', :id, :name, nil, cities, :id => city_id ),
                   :class => 'select_city_for_origin' )
    end
    
    html +
    observe_field( state_id, :update => city_id, :function => "new Ajax.Updater(#{city_id.inspect}, #{url_for(:controller => 'search', :action => 'cities').inspect}, {asynchronous:true, evalScripts:true, parameters:'state_id=' + value}); $(#{city_id.inspect}).innerHTML = '<option>#{_('Loading...')}</option>'", :with => 'state_id')
  end

  def required(content)
    content_tag('span', content, :class => 'required-field')
  end

  def required_fields_message
    content_tag('p', content_tag('span',
      _("The <label class='pseudoformlabel'>highlighted</label> fields are mandatory."),
      :class => 'required-field'
    ))
  end

  def options_for_select_with_title(container, selected = nil)
    container = container.to_a if Hash === container

    options_for_select = container.inject([]) do |options, element|
      text, value = option_text_and_value(element)
      selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
      options << %(<option title="#{html_escape(text.to_s)}" value="#{html_escape(value.to_s)}"#{selected_attribute}>#{html_escape(text.to_s)}</option>)
    end

    options_for_select.join("\n")
  end

  def balanced_table(items, per_row=3)
    items = items.map {|item| content_tag('td', item, :style => 'border: none; background: transparent;')}
    rows = []
    row = []
    counter = 0
    items.each do |item|
      counter += 1
      row << item
      if counter % per_row == 0
        rows << content_tag('tr', row.join("\n"))
        counter = 0
        row = []
      end
    end
    rows << content_tag('tr', row.join("\n"))

    content_tag('table',rows.join("\n"))
  end

  def select_folder(label_text, field_id, collection, default_value=nil, html_options = {}, js_options = {})
    root = profile ? profile.identifier : _("root")
    labelled_form_field(
      label_text,
      select_tag(
        field_id,
        options_for_select(
          [[root, '']] +
          collection.collect {|f| [ root + '/' +  f.full_name, f.id ] },
          default_value
        ),
        html_options.merge(js_options)
      )
    )
  end

  def select_profile_folder(label_text, field_id, profile, default_value='', html_options = {}, js_options = {})
    result = labelled_form_field(
      label_text,
      select_tag(
        field_id,
        options_for_select(
          [[profile.identifier, '']] +
          profile.folders.collect {|f| [ profile.identifier + '/' +  f.full_name, f.id ] },
          default_value
        ),
        html_options.merge(js_options)
      )
    )
    return result
  end

  def date_field(name, value, format = '%Y-%m-%d', datepicker_options = {}, html_options = {})
    datepicker_options[:disabled] ||= false
    datepicker_options[:alt_field] ||= ''
    datepicker_options[:alt_format] ||= ''
    datepicker_options[:append_text] ||= ''
    datepicker_options[:auto_size] ||= false
    datepicker_options[:button_image] ||= ''
    datepicker_options[:button_image_only] ||=  false
    datepicker_options[:button_text] ||= '...'
    datepicker_options[:calculate_week] ||= 'jQuery.datepicker.iso8601Week'
    datepicker_options[:change_month] ||= false
    datepicker_options[:change_year] ||= false
    datepicker_options[:close_text] ||= _('Done')
    datepicker_options[:constrain_input] ||= true
    datepicker_options[:current_text] ||= _('Today')
    datepicker_options[:date_format] ||= 'mm/dd/yy'
    datepicker_options[:day_names] ||= [_('Sunday'), _('Monday'), _('Tuesday'), _('Wednesday'), _('Thursday'), _('Friday'), _('Saturday')]
    datepicker_options[:day_names_min] ||= [_('Su'), _('Mo'), _('Tu'), _('We'), _('Th'), _('Fr'), _('Sa')]
    datepicker_options[:day_names_short] ||= [_('Sun'), _('Mon'), _('Tue'), _('Wed'), _('Thu'), _('Fri'), _('Sat')]
    datepicker_options[:default_date] ||= nil
    datepicker_options[:duration] ||= 'normal'
    datepicker_options[:first_day] ||= 0
    datepicker_options[:goto_current] ||= false
    datepicker_options[:hide_if_no_prev_next] ||= false
    datepicker_options[:is_rtl] ||= false
    datepicker_options[:max_date] ||= nil
    datepicker_options[:min_date] ||= nil
    datepicker_options[:month_names] ||= [_('January'), _('February'), _('March'), _('April'), _('May'), _('June'), _('July'), _('August'), _('September'), _('October'), _('November'), _('December')]
    datepicker_options[:month_names_short] ||= [_('Jan'), _('Feb'), _('Mar'), _('Apr'), _('May'), _('Jun'), _('Jul'), _('Aug'), _('Sep'), _('Oct'), _('Nov'), _('Dec')]
    datepicker_options[:navigation_as_date_format] ||= false
    datepicker_options[:next_text] ||= _('Next')
    datepicker_options[:number_of_months] ||= 1
    datepicker_options[:prev_text] ||= _('Prev')
    datepicker_options[:select_other_months] ||= false
    datepicker_options[:short_year_cutoff] ||= '+10'
    datepicker_options[:show_button_panel] ||= false
    datepicker_options[:show_current_at_pos] ||= 0
    datepicker_options[:show_month_after_year] ||= false
    datepicker_options[:show_on] ||= 'focus'
    datepicker_options[:show_options] ||= {}
    datepicker_options[:show_other_months] ||= false
    datepicker_options[:show_week] ||= false
    datepicker_options[:step_months] ||= 1
    datepicker_options[:week_header] ||= _('Wk')
    datepicker_options[:year_range] ||= 'c-10:c+10'
    datepicker_options[:year_suffix] ||= ''

    element_id = html_options[:id] || 'datepicker-date'
    value = value.strftime(format) if value.present?
    method = datepicker_options[:time] ? 'datetimepicker' : 'datepicker'
    result = text_field_tag(name, value, html_options)
    result +=
    "
    <script type='text/javascript'>
      jQuery('##{element_id}').#{method}({
        disabled: #{datepicker_options[:disabled].to_json},
        altField: #{datepicker_options[:alt_field].to_json},
        altFormat: #{datepicker_options[:alt_format].to_json},
        appendText: #{datepicker_options[:append_text].to_json},
        autoSize: #{datepicker_options[:auto_size].to_json},
        buttonImage: #{datepicker_options[:button_image].to_json},
        buttonImageOnly: #{datepicker_options[:button_image_only].to_json},
        buttonText: #{datepicker_options[:button_text].to_json},
        calculateWeek: #{datepicker_options[:calculate_week].to_json},
        changeMonth: #{datepicker_options[:change_month].to_json},
        changeYear: #{datepicker_options[:change_year].to_json},
        closeText: #{datepicker_options[:close_text].to_json},
        constrainInput: #{datepicker_options[:constrain_input].to_json},
        currentText: #{datepicker_options[:current_text].to_json},
        dateFormat: #{datepicker_options[:date_format].to_json},
        dayNames: #{datepicker_options[:day_names].to_json},
        dayNamesMin: #{datepicker_options[:day_names_min].to_json},
        dayNamesShort: #{datepicker_options[:day_names_short].to_json},
        defaultDate: #{datepicker_options[:default_date].to_json},
        duration: #{datepicker_options[:duration].to_json},
        firstDay: #{datepicker_options[:first_day].to_json},
        gotoCurrent: #{datepicker_options[:goto_current].to_json},
        hideIfNoPrevNext: #{datepicker_options[:hide_if_no_prev_next].to_json},
        isRTL: #{datepicker_options[:is_rtl].to_json},
        maxDate: #{datepicker_options[:max_date].to_json},
        minDate: #{datepicker_options[:min_date].to_json},
        monthNames: #{datepicker_options[:month_names].to_json},
        monthNamesShort: #{datepicker_options[:month_names_short].to_json},
        navigationAsDateFormat: #{datepicker_options[:navigation_as_date_format].to_json},
        nextText: #{datepicker_options[:next_text].to_json},
        numberOfMonths: #{datepicker_options[:number_of_months].to_json},
        prevText: #{datepicker_options[:prev_text].to_json},
        selectOtherMonths: #{datepicker_options[:select_other_months].to_json},
        shortYearCutoff: #{datepicker_options[:short_year_cutoff].to_json},
        showButtonPanel: #{datepicker_options[:show_button_panel].to_json},
        showCurrentAtPos: #{datepicker_options[:show_current_at_pos].to_json},
        showMonthAfterYear: #{datepicker_options[:show_month_after_year].to_json},
        showOn: #{datepicker_options[:show_on].to_json},
        showOptions: #{datepicker_options[:show_options].to_json},
        showOtherMonths: #{datepicker_options[:show_other_months].to_json},
        showWeek: #{datepicker_options[:show_week].to_json},
        stepMonths: #{datepicker_options[:step_months].to_json},
        weekHeader: #{datepicker_options[:week_header].to_json},
        yearRange: #{datepicker_options[:year_range].to_json},
        yearSuffix: #{datepicker_options[:year_suffix].to_json}
      })
    </script>
    "
    result
  end

  def date_range_field(from_name, to_name, from_value, to_value, format = '%Y-%m-%d', datepicker_options = {}, html_options = {})
    from_id = html_options[:from_id] || 'datepicker-from-date'
    to_id = html_options[:to_id] || 'datepicker-to-date'
    return _('From') +' '+ date_field(from_name, from_value, format, datepicker_options, html_options.merge({:id => from_id})) +
    ' ' + _('until') +' '+ date_field(to_name, to_value, format, datepicker_options, html_options.merge({:id => to_id}))
  end

  def select_folder(label_text, field_id, collection, default_value=nil, html_options = {}, js_options = {})
    root = profile ? profile.identifier : _("root")
    labelled_form_field(
      label_text,
      select_tag(
        field_id,
        options_for_select(
          [[root, '']] +
          collection.collect {|f| [ root + '/' +  f.full_name, f.id ] },
          default_value
        ),
        html_options.merge(js_options)
      )
    )
  end

  def select_profile_folder(label_text, field_id, profile, default_value='', html_options = {}, js_options = {})
    result = labelled_form_field(
      label_text,
      select_tag(
        field_id,
        options_for_select(
          [[profile.identifier, '']] +
          profile.folders.collect {|f| [ profile.identifier + '/' +  f.full_name, f.id ] },
          default_value
        ),
        html_options.merge(js_options)
      )
    )
    return result
  end

protected
  def self.next_id_number
    if defined? @@id_num
      @@id_num.next!
    else
      @@id_num = '0'
    end
  end
end

