class CreateOrganizationRatingComment < Task
  include Rails.application.routes.url_helpers

  validates_presence_of :requestor_id, :organization_rating_id, :target_id

  settings_items :organization_rating_id, :type => Integer, :default => nil
  settings_items :organization_rating_comment_id, :type => Integer, :default => nil

  attr_accessible :organization_rating_id, :body, :requestor
  attr_accessible :reject_explanation, :target

  before_save :update_comment_body

  DATA_FIELDS = ['body']
  DATA_FIELDS.each do |field|
    settings_items field.to_sym
  end

  def update_comment_body
    if self.organization_rating_comment_id.nil?
      create_comment
    else
      comment = Comment.find_by_id(self.organization_rating_comment_id)
      comment.body = get_comment_message
      comment.save
    end
  end

  def create_comment
    if (self.body && !self.body.blank?)
      comment_body = _("Comment waiting for approval")
      comment = Comment.create!(:source => self.target, :body => comment_body, :author => self.requestor)


      self.organization_rating_comment_id = comment.id
      link_comment_with_its_rating(comment)
    end
  end

  def link_comment_with_its_rating(user_comment)
    rating = OrganizationRating.find(self.organization_rating_id)
    rating.comment = user_comment
    rating.save
  end

  def get_comment_message
    if self.status == Status::CANCELLED
      _("Comment rejected")
    elsif self.status == Status::FINISHED
      self.body
    else
      _("No comment")
    end
  end

  def accept_details
    true
  end

  def title
    _("New Comment")
  end

  def information
    message = _("<a href=%{requestor_url}>%{requestor}</a> wants to create a comment in this %{target_class}") %
    {:requestor_url => url_for(self.requestor.url), :requestor => self.requestor.name, :target_class => self.target.class.name.downcase}

    {:message => message}
  end

  def reject_details
    true
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  # tells if this request was rejected
  def rejected?
    self.status == Task::Status::CANCELLED
  end

  # tells if this request was appoved
  def approved?
    self.status == Task::Status::FINISHED
  end

  def target_notification_description
    _("%{requestor} wants to create a comment in this \"%{target}\"") %
    {:requestor => self.requestor.name, :target => self.target.class.name.downcase }
  end

  def target_notification_message
    _("User \"%{user}\" just requested to create a comment in the %{target_class}
      \"%{target_name}\".
      You have to approve or reject it through the \"Pending Validations\"
      section in your control panel.\n") %
    { :user => self.requestor.name, :target_class => self.target.class.name.downcase, :target_name => self.target.name }
  end

  def task_created_message
    _("Your request for commenting at %{target} was
      just sent. Environment administrator will receive it and will approve or
      reject your request according to his methods and criteria.
      You will be notified as soon as environment administrator has a position
      about your request.") %
    { :target => self.target.name }
  end

  def task_cancelled_message
    _("Your request for commenting at %{target} was
      not approved by the environment administrator. The following explanation
      was given: \n\n%{explanation}") %
    { :target => self.target.name,
      :explanation => self.reject_explanation }
  end

  def task_finished_message
    _('Your request for commenting was approved.
      You can access %{url} to see your comment.') %
    { :url => ratings_url }
  end

  private

  def ratings_url
    url = url_for(self.target.public_profile_url) + "/plugin/organization_ratings/new_rating"
  end

end
