class CreateEnterprise < Task

  DATA_FIELDS = %w[ name identifier address contact_phone contact_person acronym foundation_year legal_form economic_activity management_information ]

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
  validates_presence_of :name, :identifier, :address, :contact_phone, :contact_person, :legal_form, :economic_activity
  validates_format_of :foundation_year, :with => /^\d*$/

  # checks for actual attributes
  validates_presence_of :requestor_id

end
