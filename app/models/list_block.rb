class ListBlock < Block

  def to_html
    content_tag(:ul, Profile.find(:all).map{|p| content_tag( :li, p.name ) })
  end
end
