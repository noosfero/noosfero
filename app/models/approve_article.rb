class ApproveArticle < Task
  serialize :data, Hash

  def data
    self[:data] ||= {} 
  end

  def article
    Article.find_by_id data[:article_id]
  end

  def article= value
    data[:article_id] = value.id
  end

  def name
    data[:name]
  end

  def name= value
    data[:name] = value
  end

  def perform
    PublishedArticle.create(:name => name, :profile => target, :reference_article => article)
  end

  def sends_email?
    true
  end
end
