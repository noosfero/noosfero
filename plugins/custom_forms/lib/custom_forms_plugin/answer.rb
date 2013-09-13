class CustomFormsPlugin::Answer < Noosfero::Plugin::ActiveRecord
  belongs_to :field, :class_name => 'CustomFormsPlugin::Field'
  belongs_to :submission, :class_name => 'CustomFormsPlugin::Submission'

  validates_presence_of :field
  validate :value_mandatory, :if => 'field.present?'

  def value_mandatory
    if field.mandatory && value.blank?
      errors.add(:value, _("is mandatory.").fix_i18n)
    end
  end
end

