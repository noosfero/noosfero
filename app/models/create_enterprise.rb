class CreateEnterprise < Task

  N_('CreateEnterprise|Identifier')
  N_('CreateEnterprise|Name')
  N_('CreateEnterprise|Address')
  N_('CreateEnterprise|Contact phone')
  N_('CreateEnterprise|Contact person')
  N_('CreateEnterprise|Acronym')
  N_('CreateEnterprise|Foundation year')
  N_('CreateEnterprise|Legal form')
  N_('CreateEnterprise|Economic activity')
  N_('CreateEnterprise|Management information')

  DATA_FIELDS = %w[ name identifier address contact_phone contact_person acronym foundation_year legal_form economic_activity management_information region_id reject_explanation ]

  serialize :data, Hash
  attr_protected :data
  def data
    self[:data] ||= Hash.new
  end

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

  # checks for virtual attributes 
  validates_presence_of :name, :identifier, :address, :contact_phone, :contact_person, :legal_form, :economic_activity, :region_id
  validates_format_of :foundation_year, :with => /^\d*$/

  # checks for actual attributes
  validates_presence_of :requestor_id, :target_id

  # check for explanation when rejecting
  validates_presence_of :reject_explanation, :if => (lambda { |record| record.status == Task::Status::CANCELLED } )

  def validate
    if self.region && self.target
      unless self.region.validators.include?(self.target)
        self.errors.add(:target, '%{fn} is not a validator for the chosen region')
      end
    end
  end

  def valid_before_selecting_target?
    if valid?
      true
    else
      self.errors.size == 1 and self.errors[:target_id]
    end
  end

  # gets the associated region for the enterprise creation
  def region(reload = false)
    if self.region_id
      if reload || @region.nil?
        @region = Region.find(self.region_id)
      end
    end
    @region
  end

  # sets the associated region for the enterprise creation
  def region=(value)
    raise ArgumentError.new("Region expected, but got #{value.class}") unless value.kind_of?(Region)

    @region = value
    self.region_id = value.id
  end

  def environment
    region ? region.environment : nil
  end

  # Rejects the enterprise registration request.
  def reject
    cancel
  end

  def rejected?
    self.status == Task::Status::CANCELLED
  end

  # Approves the enterprise registration request.
  def approve
    finish
  end

  # tells if this request was appoved 
  def approved?
    self.status == Task::Status::FINISHED
  end

  # actually creates the enterprise after the request is approved.
  def perform
    enterprise = Enterprise.new

    profile_fields = %w[ name identifier contact_phone address region_id ]
    profile_fields.each do |field|
      enterprise.send("#{field}=", self.send(field))
    end

    organization_info_data = self.data.reject do |key,value|
      profile_fields.include?(key.to_s)
    end

    enterprise.user = self.requestor.user

    enterprise.organization_info = OrganizationInfo.new(organization_info_data)
    enterprise.save!
  end

  def description
    _('Enterprise registration: "%s"') % self.name
  end

  def task_created_message
    _('Your request for registering enterprise "%{enterprise}" at %{environment} was just received. It will be reviewed by the chosen validator organization you chose, according to its methods and creteria.

      You will be notified as soon as the validator organization has a position about your request.') % { :enterprise => self.name, :environment => self.environment }
  end

  def task_finished_message
    _('Your request fo registering the enterprise "%{enterprise}" was approved. You can access %{environment} now and start entering ') % { :enterprise => self.name, :environment => self.environment }
  end

  def task_cancelled_message
    _("Your request for registering the enterprise %{enterprise} at %{environment} was NOT approved by the validator organization. The following explanation was given: \n\n%{explanation}") % { :enterprise => self.name, :environment => self.environment, :explanation => self.reject_explanation }
  end

  def target_notification_message
    msg = ""
    msg << _("Enterprise \"%{enterprise}\" just requested to enter %{environment}. You have to approve or reject it through the \"Pending Validations\" section in your control panel.\n") % { :enterprise => self.name, :environment => self.environment }
    msg << "\n"
    msg << _("The data provided by the enterprise was the following:\n") << "\n"


    msg << (_("Name: %s") % self.name) << "\n"
    msg << (_("Acronym: %s") % self.acronym) << "\n"
    msg << (_("Address: %s") % self.address) << "\n"
    msg << (_("Legal form: %s") % self.foundation_year) << "\n"
    msg << (_("Foundation Year: %d") % self.foundation_year) << "\n"
    msg << (_("Economic activity: %s") % self.economic_activity) << "\n"

    msg << _("Information about enterprise's management:\n") << self.management_information.to_s << "\n"

    msg << (_("Contact phone: %s") % self.contact_phone) << "\n"
    msg << (_("Contact person: %s") % self.contact_person) << "\n"

    msg << _('CreateEnterprise|Identifier')

    msg
  end

end
