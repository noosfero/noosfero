class ApproveComment < Task
  validates_presence_of :target_id

  settings_items :comment_attributes, :closing_statment

  validates_presence_of :comment_attributes

  def comment
    unless @comment || self.comment_attributes.nil?
      @comment = Comment.new
      @comment.assign_attributes(ActiveSupport::JSON.decode(self.comment_attributes.to_s), :without_protection => true)
    end
    @comment
  end

  def requestor_name
    requestor ? requestor.name : (comment.name || _('Anonymous'))
  end

  def article
    Article.find_by_id comment.source_id unless self.comment.nil?
  end

  def article_name
    article ? article.name : _("Article removed.")
  end

  def perform
    comment.save!
  end

  def title
    _("New comment to article")
  end

  def icon
    result = {:type => :defined_image, :src => '/images/icons-app/article-minor.png'}
    result.merge!({:url => article.url}) if article
    result
  end

  def linked_subject
    {:text => article_name, :url => article.url} if article
  end

  def information
    if article
      if requestor
        {:message => _('%{requestor} commented on the article: %{linked_subject}.')}
      else
        { :message => _('%{requestor} commented on the article: %{linked_subject}.'),
          :variables => {:requestor => requestor_name} }
      end
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
      _('%{requestor} wants to comment the article: %{article}.') % {:requestor => requestor_name, :article => article.name}
    else
      _('%{requestor} wanted to comment the article but it was removed.') % {:requestor => requestor_name}
    end
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You need to login on %{system} in order to approve or reject this comment.') % { :system => target.environment.name }
  end

  def task_finished_message
    if !closing_statment.blank?
      _("Your comment to the article \"%{article}\" was approved. Here is the comment left by the admin who approved your comment:\n\n%{comment} ") % {:article => article_name, :comment => closing_statment}
    else
      _('Your request for comment the article "%{article}" was approved.') % {:article => article_name}
    end
  end

  def task_cancelled_message
    message = _('Your request for commenting the article "%{article}" was rejected.') % {:article => article_name}
    if !reject_explanation.blank?
      message += " " + _("Here is the reject explanation left by the administrator who rejected your comment: \n\n%{reject_explanation}") % {:reject_explanation => reject_explanation}
    end
    message
  end

end
