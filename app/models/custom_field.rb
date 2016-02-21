class CustomField < ApplicationRecord

  attr_accessible :name, :default_value, :format, :extras, :customized_type, :active, :required, :signup, :environment, :moderation_task
  serialize :customized_type
  serialize :extras
  has_many :custom_field_values, :dependent => :delete_all
  belongs_to :environment

  validates_presence_of :name, :format, :customized_type, :environment
  validate :related_to_other?
  validate :unique?

  def unique?
    if environment.custom_fields.any?{|cf| cf.name==name && cf.environment == environment && cf.customized_type==customized_type && new_record?}
      errors.add(:body, N_("There is a field with the same name for this type in this environment"))
      return false
    end
    true
  end

  def related_to_other?
    environment.custom_fields.any? do |cf|
      if cf.name == name && cf.customized_type != customized_type
        ancestor = cf.customized_type.constantize < customized_type.constantize
        descendant = cf.customized_type.constantize > customized_type.constantize
        if ancestor || descendant
          errors.add(:body, N_("New field related to existent one with same name"))
          return false
        end
      end
    end
    true
  end
end

