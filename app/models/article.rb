class Article

  acts_as_taggable  
  
#  acts_as_ferret :fields => [:title, :body]
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

  # FIXME add code from Category to make article acts as a "file system"

end
