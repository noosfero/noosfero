module DocumentHelper

  # displays an icon corresponding to the document passed in +doc+.
  #
  # The class of the document can define its icon by providing an +icon+
  # method (i.e. +doc.class.icon+ will be called)
  def icon_for_document(doc)
    icon =
      case doc
        when Comatose::Page
          'text-x-generic'
        else
          if doc.class.respond_to?(:icon)
            doc.class.icon
          else
            'none'
          end
        end
    design_display_icon(icon)
  end

end
