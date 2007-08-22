module DocumentHelper

  def icon_for_document(doc)
    design_display_icon(doc.class.icon)
  end

end
