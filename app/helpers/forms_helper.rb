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
    content_tag( 'label', human_name, :for => options[:id] )
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
