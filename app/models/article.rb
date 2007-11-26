class Article < ActiveRecord::Base

  belongs_to :profile
  validates_presence_of :profile_id, :name, :slug, :path

  acts_as_taggable  

  acts_as_filesystem

  acts_as_versioned

end
