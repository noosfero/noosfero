class CreateOrganizationRatingComment < Task
  include Rails.application.routes.url_helpers

  validates_presence_of :requestor_id, :organization_rating_id, :target_id

  settings_items :organization_rating_id, :type => Integer, :default => nil
  settings_items :organization_rating_comment_id, :type => Integer, :default => nil

  attr_accessible :organization_rating_id, :body, :requestor
  attr_accessible :reject_explanation, :target

  DATA_FIELDS = ['body']
  DATA_FIELDS.each do |field|
    settings_items field.to_sym
  end

  def perform
    if (self.body && !self.body.blank?)
      comment = Comment.create!(:source => self.target, :body => self.body, :author => self.requestor)

      self.organization_rating_comment_id = comment.id
      link_comment_with_its_rating(comment)
    end
  end

  def link_comment_with_its_rating(user_comment)
    rating = OrganizationRating.find(self.organization_rating_id)
    rating.comment = user_comment
    rating.save
  end

  def accept_details
    true
  end

  def title
    _("New Report")
  end

  def information
    message = _("<a href=%{requestor_url}>%{requestor}</a> wants to leave a report about this %{target_class}") %
    {:requestor_url => url_for(self.requestor.url), :requestor => self.requestor.name, :target_class => _(self.target.class.name)}

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
    _("%{requestor} wants to leave a report about this \"%{target}\"") %
    {:requestor => self.requestor.name, :target => _(self.target.class.name.downcase) }
  end

  def target_notification_message
    _("User \"%{user}\" just made a report at %{target_class}
      \"%{target_name}\".
      You have to approve or reject it through the \"Pending Validations\"
      section in your control panel.\n") %
    { :user => self.requestor.name,
      :target_class => _(self.target.class.name.downcase),
      :target_name => self.target.name }
  end

  def task_created_message
    _("Your report at %{target_class} \"%{target}\" was
      just sent. The administrator will receive it and will approve or
      reject your request according to his methods and criteria.
      You will be notified as soon as environment administrator has a position
      about your request.") %
    { :target_class => _(self.target.class.name.downcase), :target => self.target.name }
  end

  def task_cancelled_message
    _("Your report at %{target_class} \"%{target}\" was
      not approved by the administrator. The following explanation
      was given: \n\n%{explanation}") %
    { :target_class => _(self.target.class.name.downcase),
      :target => self.target.name,
      :explanation => self.reject_explanation }
  end

  def task_finished_message
    _("Your report at %{target_class} \"%{target}\" was approved.
      You can access %{url} to see your comment.") %
    { :target_class => _(self.target.class.name.downcase), :target => self.target.name, :url => ratings_url }
  end

  private

  def ratings_url
    url_for(self.target.public_profile_url) + "/plugin/organization_ratings/new_rating"
  end

end
