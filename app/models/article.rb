class Article < Comatose::Page
  acts_as_taggable  
  
  def keywords
    tag_list.to_s
  end
  
  def keywords=(list_tag)
    self.tag_list = list_tag
  end

  def has_keyword?(keyword)
    tags.map{|t| t.name.downcase}.include?(keyword.downcase)
  end

  def profile(reload = false)
    @profile = nil if reload
    @profile ||= Profile.find_by_identifier(self.full_path.split(/\//).first)
  end

end
