class ListBlock < Block

  def to_html
    str = "content_tag(:ul, [" + 
      User.find_all.map{|u| 
      "content_tag( :li, '#{u.name}' )" }.join(',') + "])"
    return str
  end
end
