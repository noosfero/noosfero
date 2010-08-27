class CreateEnterprise < Task

  N_('Identifier')
  N_('Name')
  N_('Address')
  N_('Contact phone')
  N_('Contact person')
  N_('Acronym')
  N_('Foundation year')
  N_('Legal form')
  N_('Economic activity')
  N_('Management information')

  DATA_FIELDS = Enterprise.fields + %w[name identifier region_id reject_explanation]

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
  validates_presence_of :name, :identifier

  #checks if the validation method is region to validates
  validates_presence_of :region_id, :if => lambda { |obj| obj.environment.organization_approval_method == :region }

  validates_format_of :foundation_year, :with => /^\d*$/

  # checks for actual attributes
  validates_presence_of :requestor_id, :target_id

  # checks for admins required attributes
  DATA_FIELDS.each do |attribute|
    validates_presence_of attribute, :if => lambda { |obj| obj.environment.required_enterprise_fields.include?(attribute) }
  end

  # check for explanation when rejecting
  validates_presence_of :reject_explanation, :if => (lambda { |record| record.status == Task::Status::CANCELLED } )

  xss_terminate :only => [ :acronym, :address, :contact_person, :contact_phone, :economic_activity, :legal_form, :management_information, :name ], :on => 'validation'

  def validate

    if self.region && self.target
      unless self.region.validators.include?(self.target) || self.target_type == "Environment"
        self.errors.add(:target, '%{fn} is not a validator for the chosen region')
      end
    end

    if self.status != Task::Status::CANCELLED && self.identifier && Profile.exists?(:identifier => self.identifier)
      self.errors.add(:identifier, '%{fn} is already being as identifier by another enterprise, organization or person.')
    end
  end

  def valid_before_selecting_target?
    if valid?
      true
    else
      self.errors.size == 1 && !self.errors[:target_id].nil?
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
    requestor.environment
  end

  def available_regions
    environment.regions.with_validators
  end

  def active_fields
    environment ? environment.active_enterprise_fields : []
  end

  def required_fields
    environment ? environment.required_enterprise_fields : []
  end

  def signup_fields
    environment ? environment.signup_enterprise_fields : []
  end

  def community?
    false
  end

  def enterprise?
    true
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

    DATA_FIELDS.reject{|field| field == "reject_explanation"}.each do |field|
      enterprise.send("#{field}=", self.send(field))
    end

    enterprise.environment = environment

    enterprise.user = self.requestor.user

    enterprise.save!
    enterprise.add_admin(enterprise.user.person)
  end

  def description
    __('Enterprise registration: "%s"') % self.name
  end

  def task_created_message
    _('Your request for registering enterprise "%{enterprise}" at %{environment} was just received. It will be reviewed by the validator organization of your choice, according to its methods and criteria.

      You will be notified as soon as the validator organization has a position about your request.') % { :enterprise => self.name, :environment => self.environment }
  end

  def task_finished_message
    __('Your request for registering the enterprise "%{enterprise}" was approved. You can access %{environment} now and provide start providing all relevant information your new enterprise.') % { :enterprise => self.name, :environment => self.environment }
  end

  def task_cancelled_message
    __("Your request for registering the enterprise %{enterprise} at %{environment} was NOT approved by the validator organization. The following explanation was given: \n\n%{explanation}") % { :enterprise => self.name, :environment => self.environment, :explanation => self.reject_explanation }
  end

  def target_notification_message
    msg = ""
    msg << __("Enterprise \"%{enterprise}\" just requested to enter %{environment}. You have to approve or reject it through the \"Pending Validations\" section in your control panel.\n") % { :enterprise => self.name, :environment => self.environment }
    msg << "\n"
    msg << __("The data provided by the enterprise was the following:\n") << "\n"


    msg << (_("Name: %s") % self.name) << "\n"
    msg << (_("Acronym: %s") % self.acronym) << "\n"
    msg << (_("Address: %s") % self.address) << "\n"
    msg << (_("Legal form: %s") % self.legal_form) << "\n"
    msg << (_("Foundation Year: %d") % self.foundation_year) << "\n" unless self.foundation_year.blank?
    msg << (_("Economic activity: %s") % self.economic_activity) << "\n"

    msg << __("Information about enterprise's management:\n") << self.management_information.to_s << "\n"

    msg << (_("Contact phone: %s") % self.contact_phone) << "\n"
    msg << (_("Contact person: %s") % self.contact_person) << "\n"

    msg << __('CreateEnterprise|Identifier')

    msg
  end

  def permission
    :validate_enterprise
  end

end
