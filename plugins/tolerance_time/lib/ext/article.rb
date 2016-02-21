require_dependency 'article'

class Article
  after_create do |article|
    ToleranceTimePlugin::Publication.create!(:target => article) if article.published
  end

  before_save do |article|
    if article.published_changed?
      if article.published
        ToleranceTimePlugin::Publication.create!(:target => article)
      else
        publication = ToleranceTimePlugin::Publication.find_by target: article
        publication.destroy if publication.present?
      end
    end
  end

  before_destroy do |article|
    publication = ToleranceTimePlugin::Publication.find_by target: article
    publication.destroy if publication.present?
  end
end
