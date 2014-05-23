class CustomFormsPlugin::Answer < ActiveRecord::Base
  set_table_name :custom_forms_plugin_answers
  belongs_to :field, :class_name => 'CustomFormsPlugin::Field'
  belongs_to :submission, :class_name => 'CustomFormsPlugin::Submission'

  validates_presence_of :field
  validate :value_mandatory, :if => 'field.present?'

  attr_accessible :field, :value, :submission

  def value_mandatory
    if field.mandatory && value.blank?
      errors.add(:value, _("is mandatory.").fix_i18n)
    end
  end

  def to_s
    return value if value.blank? || field.alternatives.blank?
    selected = value.split(',')
    field.alternatives.select {|alt| selected.include? alt.id.to_s }.map(&:label).join(';')
  end
end

