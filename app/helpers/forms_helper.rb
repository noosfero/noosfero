module FormsHelper

  # create a form field structure (as if it were generated with
  # labelled_form_for), but with a customized control and label.
  #
  # If +field_id+ is not given, the underlying implementation will try to guess
  # it from +field_html+ using a regular expression. In this case, make sure
  # that the first ocurrance of id=['"]([^'"]*)['"] in +field_html+ if the one
  # you want (i.e. the correct id for the control )
  def labelled_form_field(label, field_html, field_id = nil)
    NoosferoFormBuilder::output_field(label, field_html, field_id)
  end

  alias_method :display_form_field, :labelled_form_field

  def labelled_fields_for(name, object = nil, options = {}, &proc)
    object ||= instance_variable_get("@#{name}")
    fields_for(name, object, { :builder => NoosferoFormBuilder }.merge(options), &proc)
  end

  def labelled_form_for(name, object = nil, options = {}, &proc)
    object ||= instance_variable_get("@#{name}")
    form_for(name, object, { :builder => NoosferoFormBuilder }.merge(options), &proc)
  end

  class NoosferoFormBuilder < ActionView::Helpers::FormBuilder
    include GetText
    extend ActionView::Helpers::TagHelper

    def self.output_field(text, field_html, field_id = nil)
      # try to guess an id if none given
      if field_id.nil?
        field_html =~ /id=['"]([^'"]*)['"]/
        field_id = $1
      end
      field_html =~ /type=['"]([^'"]*)['"]/
      field_html =~ /<(\w*)/ unless $1
      field_type = $1
      field_class = 'formfield type-' + field_type if field_type

      label_html = content_tag('label', _(text), :class => 'formlabel', :for => field_id)
      control_html = content_tag('div', field_html, :class => field_class )

      content_tag('div', label_html + control_html, :class => 'formfieldline' )
    end

    (field_helpers - %w(hidden_field)).each do |selector|
      src = <<-END_SRC
        def #{selector}(field, *args, &proc)
          column = object.class.columns_hash[field.to_s]
          text =
            ( column ?
              column.human_name :
              _(field.to_s.humanize)
            )

          NoosferoFormBuilder::output_field(text, super)
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
    
    # Create a formatable radio collection
    # Tha values parameter is a array of [value, label] arrays like this:
    # [ ['en',_('English')], ['pt',_('Portuguese')], ['es',_('Spanish')] ]
    # The option :size will set how many radios will be showed in each line
    # Example: use :size => 3 as option if you want 3 radios by line
    def radio_group( object_name, method, values, options = {} )
      line_size = options[:size] || 0
      line_item = 0
      html = "\n"
      values.each { |val, h_val|
        id = object_name.to_s() +'_'+ method.to_s() +'_'+ val.to_s()
        # Não está apresentando o sexo selecionado ao revisitar
        # http://localhost:3000/myprofile/manuel/profile_editor/edit  :-(
        html += self.class.content_tag( 'span',
            @template.radio_button( object_name, method, val,
                                    :id => id, :object => @object ) +
            self.class.content_tag( 'label', h_val, :for => id ),
            :class => 'lineitem' + (line_item+=1).to_s() ) +"\n"
        if line_item == line_size
          line_item = 0
          html += "<br />\n"
        end
      }
      html += "<br />\n"  if line_size == 0 || ( values.size % line_size ) > 0
      column = object.class.columns_hash[method.to_s]
      text =
        ( column ?
          column.human_name :
          _(method.to_s.humanize)
        )
      label_html = self.class.content_tag 'label', text,
                                        :class => 'formlabel'
      control_html = self.class.content_tag 'div', html,
                                        :class => 'formfield type-radio '+
                                        'fieldgroup linesize'+line_size.to_s()

      self.class.content_tag 'div', label_html + control_html,
                                          :class => 'formfieldline'
    end
    
  end


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
    content_tag( 'label', human_name, :for => options[:id] )
  end

  def labelled_text_field( human_name, name, value=nil, options={} )
    options[:id] ||= 'text-field-' + FormsHelper.next_id_number
    content_tag('label', human_name, :for => options[:id]) +
    text_field_tag( name, value, options )
  end

  def labelled_select( human_name, name, value_method, text_method, selected, collection, options )
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

protected
  def self.next_id_number
    if defined? @@id_num
      @@id_num.next!
    else
      @@id_num = '0'
    end
  end
end

