class Article < Comatose::Page
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

  def title=(value)
    super
    # taken from comatose, added a call to transliterate right before downcase.
    if (self[:slug].nil? or self[:slug].empty?) and !self[:title].nil?
      self[:slug] = self[:title].transliterate.downcase.gsub( /[^-a-z0-9~\s\.:;+=_]/, '').gsub(/[\s\.:;=_+]+/, '-').gsub(/[\-]{2,}/, '-').to_s
    end
  end

end
