class LinkBlock < Block
  def to_html 
    users = User.find(:all).map do |u|
      content_tag("a href='http://www.google.com.br'",  u.name)
    end
    users.join(',')
  end
end
