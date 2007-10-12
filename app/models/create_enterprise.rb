class CreateEnterprise < Task

  DATA_FIELDS = %w[ name identifier address contact_phone contact_person acronym foundation_year legal_form economic_activity management_information region_id ]

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

  def validate
    if self.region && self.target
      unless self.region.validators.include?(self.target)
        self.errors.add(:target, '%{fn} is not a validator for the chosen region')
      end
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

  # Rejects the enterprise registration request.
  def reject
    cancel
  end

  # Approves the enterprise registration request.
  def approve
    finish
  end

  # actually creates the enterprise after the request is approved.
  def perform
    enterprise = Enterprise.new

    profile_fields = %w[ name identifier contact_phone address region_id ]
    profile_fields.each do |field|
      enterprise.send("#{field}=", self.send(field))
    end

    organization_info_data = self.data.delete_if do |key,value|
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
    
  end

  def task_finished_message
  end

  def task_cancelled_message
  end


end
