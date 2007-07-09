class ListBlock < Block

  def to_html
    content_tag(:ul, User.find(:all).map{|u| content_tag( :li, u.name ) })
  end
end
