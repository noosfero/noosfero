class CreateCommunity < Task

  validates_presence_of :requestor_id, :target_id
  validates_presence_of :name

  validates :requestor, kind_of: {kind: Person}
  validates :target, kind_of: {kind: Environment}

  alias :environment :target
  alias :environment= :target=

  attr_accessible :environment, :requestor, :target
  attr_accessible :reject_explanation, :template_id

  acts_as_having_image

  DATA_FIELDS = Community.fields + ['name', 'closed', 'description']
  DATA_FIELDS.each do |field|
    settings_items field.to_sym
    attr_accessible field.to_sym
  end

  settings_items :custom_values
  attr_accessible :custom_values

  def validate
    self.environment.required_community_fields.each do |field|
      if self.send(field).blank?
        self.errors.add_on_blank(field)
      end
    end
  end

  def perform
    community = Community.new
    community_data = self.data.reject do |key, value|
      ! DATA_FIELDS.include?(key.to_s)
    end

    community.update(community_data)
    community.image = image if image
    community.custom_values = custom_values
    community.environment = self.environment
    community.save!
    community.add_admin(self.requestor)
  end

  def title
    _("New community")
  end

  def icon
    src = image ? image.public_filename(:minor) : '/images/icons-app/community-minor.png'
    {:type => :defined_image, :src => src, :name => name}
  end

  def subject
    name
  end

  def information
    if description.blank?
      { :message => _('%{requestor} wants to create community %{subject} with no description.') }
    else
      { :message => _('%{requestor} wants to create community %{subject} with this description:<p><em>%{description}</em></p>'),
        :variables => {:description => description} }
    end
  end

  def reject_details
    true
  end

  def custom_fields_moderate
    true
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
    _('%{requestor} wants to create community %{subject}') % {:requestor => requestor.name, :subject => subject}
  end

  def target_notification_message
    _("User \"%{user}\" just requested to create community %{community}. You have to approve or reject it through the \"Pending Validations\" section in your control panel.\n") % { :user => self.requestor.name, :community => self.name }
  end

  def task_created_message
    _("Your request for registering community %{community} at %{environment} was just sent. Environment administrator will receive it and will approve or reject your request according to his methods and creteria.

      You will be notified as soon as environment administrator has a position about your request.") % { :community => self.name, :environment => self.target }
  end

  def task_cancelled_message
    _("Your request for registering community %{community} at %{environment} was not approved by the environment administrator. The following explanation was given: \n\n%{explanation}") % { :community => self.name, :environment => self.environment, :explanation => self.reject_explanation }
  end

  def task_finished_message
    _('Your request for registering the community "%{community}" was approved. You can access %{environment} now and start using your new community.') % { :community => self.name, :environment => self.environment }
  end

end
