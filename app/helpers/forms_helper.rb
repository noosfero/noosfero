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
    check_box_tag( name, value, checked, options ) +
      content_tag( 'label', human_name, :for => options[:id] ) +
      hidden_field_tag(name, '0')
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

protected
  def self.next_id_number
    if defined? @@id_num
      @@id_num.next!
    else
      @@id_num = '0'
    end
  end
end

