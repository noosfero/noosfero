class CreateCustomFormsPluginFields < ActiveRecord::Migration
  def self.up
    create_table :custom_forms_plugin_fields do |t|
      t.string :name
      t.string :slug
      t.string :type
      t.string :default_value
      t.string :choices
      t.float  :minimum
      t.float  :maximum
      t.references :form
      t.boolean :mandatory, :default => false
      t.boolean :multiple
      t.boolean :list
    end
  end

  def self.down
    drop_table :custom_forms_plugin_fields
  end
end
