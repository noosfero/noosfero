module ThickboxHelper
  def thickbox_inline_popup_link(title, url, id, options = {})
    link_to(title, url_for(url) + "#TB_inline?height=300&width=500&inlineId=#{id}&modal=true", {:class => 'thickbox'}.merge(options))
  end
  def thickbox_inline_popup_icon(type, title, url, id, options = {})
    icon_button(type, title, url_for(url) + "#TB_inline?height=300&width=500&inlineId=#{id}&modal=true", {:class => "thickbox"}.merge(options))
  end
  def thickbox_close_button(title)
    button_to_function(:close, title, 'tb_remove();')
  end
end
