class CreateCommunity < Task

  validates_presence_of :requestor_id, :target_id
  validates_presence_of :name

  alias :environment :target
  alias :environment= :target=

  serialize :data, Hash
  attr_protected :data
  def data
    self[:data] ||= Hash.new
  end

  acts_as_having_image

  DATA_FIELDS = Community.fields + ['name', 'closed', 'tag_list']

  DATA_FIELDS.each do |field|
    # getter
    define_method(field) do
      self.data[field.to_sym]
    end
    # setter
    define_method("#{field}=") do |value|
      self.data[field.to_sym] = value
    end
  end

  def validate
    self.environment.required_community_fields.each do |field|
      if self.send(field).blank?
        self.errors.add(field, _('%{fn} is mandatory'))
      end
    end
  end

  def perform
    community = Community.new
    community_data = self.data.reject do |key, value|
      ! DATA_FIELDS.include?(key.to_s)
    end

    community.update_attributes(community_data)
    community.image = image if image
    community.environment = self.environment
    community.save!
    community.add_admin(self.requestor)
  end

  def description
    _('%s wants to create community %s.') % [requestor.name, self.name]
  end

  def closing_statement
    data[:closing_statement]
  end

  def closing_statement= value
    data[:closing_statement] = value
  end

  # tells if this request was rejected
  def rejected?
    self.status == Task::Status::CANCELLED
  end

  # tells if this request was appoved
  def approved?
    self.status == Task::Status::FINISHED
  end

  def target_notification_message
    description + "\n\n" +
    _("User \"%{user}\" just requested to create community %{community}. You have to approve or reject it through the \"Pending Validations\" section in your control panel.\n") % { :user => self.requestor.name, :community => self.name }
  end

  def task_created_message
    _("Your request for registering community %{community} at %{environment} was just sent. Environment administrator will receive it and will approve or reject your request according to his methods and creteria.

      You will be notified as soon as environment administrator has a position about your request.") % { :community => self.name, :environment => self.target }
  end

  def task_cancelled_message
    _("Your request for registering community %{community} at %{environment} was not approved by the environment administrator. The following explanation was given: \n\n%{explanation}") % { :community => self.name, :environment => self.environment, :explanation => self.closing_statement }
  end

  def task_finished_message
    _('Your request for registering the community "%{community}" was approved. You can access %{environment} now and start using your new community.') % { :community => self.name, :environment => self.environment }
  end

end
