require_dependency 'organization'

Organization.class_eval do
  has_many :organization_ratings

  has_many :comments, -> { order 'created_at asc' }, class_name: 'Comment', foreign_key: 'source_id', dependent: :destroy
end
