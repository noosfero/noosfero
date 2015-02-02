class CustomFormsPlugin::Alternative < ActiveRecord::Base
  set_table_name :custom_forms_plugin_alternatives

  validates_presence_of :label

  belongs_to :field, :class_name => 'CustomFormsPlugin::Field'

  attr_accessible :label, :field, :position, :selected_by_default
end

