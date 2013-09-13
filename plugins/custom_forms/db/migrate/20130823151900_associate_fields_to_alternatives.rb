class AssociateFieldsToAlternatives < ActiveRecord::Migration
  class CustomFormsPlugin::Field < ActiveRecord::Base
    set_table_name :custom_forms_plugin_fields
    has_many :alternatives, :class_name => 'CustomFormsPlugin::Alternative'
    serialize :choices, Hash
  end

  def self.up
    CustomFormsPlugin::Field.reset_column_information

    CustomFormsPlugin::Field.find_each do |f|
      f.choices.each do |key, value|
        CustomFormsPlugin::Alternative.create!(:label => key, :field_id => f.id)
      end
    end

    change_table :custom_forms_plugin_fields do |t|
      t.remove :choices
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
