require_dependency 'comment'

class Comment
  after_create do |comment|
    ToleranceTimePlugin::Publication.create!(:target => comment)
  end

  before_destroy do |comment|
    publication = ToleranceTimePlugin::Publication.find_by target: comment
    publication.destroy if publication.present?
  end
end

