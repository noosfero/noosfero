class CustomFieldValue < ApplicationRecord

  belongs_to :custom_field
  belongs_to :customized, :polymorphic => true
  attr_accessible :value, :public, :customized, :custom_field, :customized_type
  validate :can_save?

  scope :only_public, -> { where(:public => true) }
  scope :not_public, -> { where(:public => false) } 
  scope :by_field, lambda { |field| self.joins(:custom_field).where("custom_fields.name = ?", field) } 

  def can_save?
    if value.blank? && custom_field.required
      errors.add(custom_field.name, _("can't be blank"))
      return false
    end
    return true
  end
end
