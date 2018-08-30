class CustomFormsPlugin::FormAnswer < ApplicationRecord
  self.table_name = :custom_forms_plugin_form_answers
  belongs_to :alternative, :class_name => 'CustomFormsPlugin::Alternative'
  belongs_to :answer, :class_name => 'CustomFormsPlugin::Answer'
end
