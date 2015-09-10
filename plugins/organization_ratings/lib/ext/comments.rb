require_dependency "comment"

Comment.class_eval do

  has_one :organization_rating
end
