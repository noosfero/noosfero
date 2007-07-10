class LinkBlock < Block
  def to_html 
    profiles = Profile.find(:all).map do |p|
      content_tag("a href='http://www.google.com.br'",  p.name)
    end
    profiles.join(',')
  end
end
