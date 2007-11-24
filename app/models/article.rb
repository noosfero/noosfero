class Article < ActiveRecord::Base

  acts_as_taggable  

  acts_as_filesystem

  acts_as_versioned

  def profile(reload = false)
    @profile = nil if reload
    @profile ||= Profile.find_by_identifier(self.full_path.split(/\//).first)
  end

end
