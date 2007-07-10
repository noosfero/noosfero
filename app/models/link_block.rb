class LinkBlock < Block

  # Redefinition of to_html Block method that show a list of links showing the Profile name.
  #
  # Ex:
  #
  # <a href="http://www.colivre.coop.br"> Colivre </a> 
  #
  # <a href="http://www.ba.softwarelivre.org"> PSL-BA </a> 
  def to_html 
    profiles = Profile.find(:all).map do |p|
      content_tag("a href='http://www.google.com.br'",  p.name)
    end
    profiles.join(',')
  end
end
