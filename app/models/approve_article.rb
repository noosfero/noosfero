class ApproveArticle < Task
  serialize :data, Hash

  validates_presence_of :requestor_id, :target_id

  def description
    _('%{author} wants to publish "%{article}" on %{community}') % { :author => requestor.name, :article => article_title, :community => target.name }
  end

  def article_title
    article ? article.title : _('(The original text was removed)')
  end
  
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

  def closing_statment
    data[:closing_statment]
  end
  
  def closing_statment= value
    data[:closing_statment] = value
  end

  def article_parent_id= value
    data[:parent_id] = value
  end

  def article_parent_id
    data[:parent_id]
  end

  def article_parent
    Article.find_by_id article_parent_id.to_i
  end

  def article_parent= value
    self.article_parent_id = value.id
  end

  def highlighted= value
    data[:highlighted] = value
  end

  def highlighted
    data[:highlighted]
  end

  def perform
    if article.event?
      article.copy(:name => name, :profile => target, :reference_article => article)
    else
      PublishedArticle.create!(:name => name, :profile => target, :reference_article => article, :parent => article_parent, :highlighted => highlighted, :source => article.source)
    end
  end

  def target_notification_message
    return nil if target.organization? && !target.moderated_articles?
    description + "\n\n" +
    _('You need to login on %{system} in order to approve or reject this article.') % { :system => target.environment.name }
  end

end
