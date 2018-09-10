class CustomFormsPlugin::Alternative < ApplicationRecord
  self.table_name = :custom_forms_plugin_alternatives

  validates_presence_of :label

  belongs_to :field, :class_name => 'CustomFormsPlugin::Field', optional: true
  has_many :form_answers, :class_name => 'CustomFormsPlugin::FormAnswer'
  has_many :answers, :through => :form_answers

  attr_accessible :label, :field, :position, :selected_by_default
end
