class ApproveArticle < Task
  validates_presence_of :requestor_id, :target_id

  validates :requestor, kind_of: {kind: Person}
  validate :allowed_requestor

  def allowed_requestor
    if target
      if target.person? && requestor != target
        self.errors.add(:requestor, _('You can not post articles to other users.'))
      end
      if target.organization? && !target.members.include?(requestor) && target.environment.portal_community != target
        self.errors.add(:requestor, _('Only members can post articles on communities.'))
      end
    end
  end

  def article_title
    article ? article.title : _('(The original text was removed)')
  end

  def article
    Article.find_by_id data[:article_id]
  end

  def article= value
    data[:article_id] = value.id
  end

  def name
    data[:name].blank? ? (article ? article.name : _("Article removed.")) : data[:name]
  end

  def name= value
    data[:name] = value
  end

  settings_items :closing_statment, :article_parent_id, :highlighted
  settings_items :create_link, :type => :boolean, :default => false

  def article_parent
    Article.find_by_id article_parent_id.to_i
  end

  def article_parent= value
    self.article_parent_id = value.id
  end

  def abstract= value
    data[:abstract] = value
  end

  def abstract
    data[:abstract].blank? ? (article ? article.abstract : '') : data[:abstract]
  end

  def body= value
    data[:body] = value
  end

  def body
    data[:body].blank? ? (article ? article.body : "") : data[:body]
  end

  def perform
    if create_link
      LinkArticle.create!(:reference_article => article, :profile => target, :parent => article_parent, :highlighted => highlighted)
    else
      article.copy!(:name => name, :abstract => abstract, :body => body, :profile => target, :reference_article => article, :parent => article_parent, :highlighted => highlighted, :source => article.source, :last_changed_by_id => article.last_changed_by_id, :created_by_id => article.created_by_id)
    end
  end

  def title
    _("New article")
  end

  def icon
    result = {:type => :defined_image, :src => '/images/icons-app/article-minor.png', :name => name}
    result.merge({:url => article.url}) if article
    return result
  end

  def linked_subject
    {:text => name, :url => article.url} if article
  end

  def information
    if article
      {:message => _('%{requestor} wants to publish the article: %{linked_subject}.')}
    else
      {:message => _("The article was removed.")}
    end
  end

  def accept_details
    true
  end

  def reject_details
    true
  end

  def default_decision
    if article
      'skip'
    else
      'reject'
    end
  end

  def accept_disabled?
    article.blank?
  end

  def target_notification_description
    if article
      _('%{requestor} wants to publish the article: %{article}.') % {:requestor => requestor.name, :article => article.name}
    else
      _('%{requestor} wanted to publish an article but it was removed.') % {:requestor => requestor.name}
    end
  end

  def target_notification_message
    return nil if target.organization? && !target.moderated_articles?
    target_notification_description + "\n\n" +
    _('You need to login on %{system} in order to approve or reject this article.') % { :system => target.environment.name }
  end

  def task_finished_message
    if !closing_statment.blank?
      _("Your request for publishing the article \"%{article}\" was approved. Here is the comment left by the admin who approved your article:\n\n%{comment} ") % {:article => name, :comment => closing_statment}
    else
      _('Your request for publishing the article "%{article}" was approved.') % {:article => name}
    end
  end

  def task_cancelled_message
    message = _('Your request for publishing the article "%{article}" was rejected.') % {:article => name}
    if !reject_explanation.blank?
      message += " " + _("Here is the reject explanation left by the administrator who rejected your article: \n\n%{reject_explanation}") % {:reject_explanation => reject_explanation}
    end
    message
  end

end
