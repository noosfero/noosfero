##
# DEPRECATED ActionView::TestCase already provide all needed
#
module NoosferoTestHelper


  def submit_tag(content, options = {})
    content
  end

  def remote_function(options = {})
    ''
  end

  def options_from_collection_for_select(collection, value_method, content_method)
    "<option value='fake value'>fake content</option>"
  end

  def select_tag(id, collection, options = {})
    "<select id='#{id}'>fake content</select>"
  end

  def options_for_select(collection, selected = nil)
    collection.map{|item| "<option value='#{item[1]}'>#{item[0]}</option>"}.join("\n")
  end

  def params
    {}
  end

  def ui_icon(icon)
    icon
  end

  def will_paginate(arg1, arg2)
  end

  def javascript_tag(any)
    ''
  end
  def javascript_include_tag(any)
    ''
  end
  def check_box_tag(name, value = 1, checked = false, options = {})
    name
  end
  def stylesheet_link_tag(arg)
    arg
  end

  def strip_tags(html)
    html.gsub(/<[^>]+>/, '')
  end

  def icon_for_article(article)
    ''
  end

end

