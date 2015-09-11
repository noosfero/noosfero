require_dependency 'organization'

Organization.class_eval do
  has_many :organization_ratings

  has_many :comments, :class_name => 'Comment', :foreign_key => 'source_id', :dependent => :destroy, :order => 'created_at asc'
end
