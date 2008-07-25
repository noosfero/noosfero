module ThickboxHelper
  def thickbox_inline_popup_link(title, id, options = {})
    link_to(title, "#TB_inline?height=300&width=500&inlineId=#{id}&modal=true", {:class => 'thickbox'}.merge(options))
  end
  def thickbox_close_button(title)
    button_to_function(:close, title, 'tb_remove();')
  end
end
