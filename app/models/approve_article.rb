class ApproveArticle < Task
  serialize :data, Hash

  validates_presence_of :requestor_id, :target_id

  def description
    _('%{author} wants to publish "%{article}" on %{community}') % { :author => requestor.name, :article => article.title, :community => target.name }
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

  def perform
    PublishedArticle.create(:name => name, :profile => target, :reference_article => article)
  end

  def target_notification_message
    description + "\n\n" +
    _('You need to login on %{system} in order to approve or reject this article. You can use the address below to do that.') % { :system => target.environment.name }
  end

end
