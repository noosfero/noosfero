class LinkBlock < Block
  def to_html 
    str = 'content_tag(:p,[' + 
      User.find_all.map{ |u|   
        "[link_to '"+u.name + "', {:controller => 'user', :action => 'test'}]"}.join(',') +
      "])"
    return str 
  end
end
