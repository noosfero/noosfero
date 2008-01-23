module FormsHelper

  def generate_form( name, obj, fields={} )

    labelled_form_for name, obj do |f|

      f.text_field(:name)

    end

  end

end
