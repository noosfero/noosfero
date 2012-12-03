class CreateCustomFormsPluginForms < ActiveRecord::Migration
  def self.up
    create_table :custom_forms_plugin_forms do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.references :profile
      t.datetime :begining
      t.datetime :ending
      t.boolean :report_submissions, :default => false
      t.boolean :on_membership, :default => false
      t.string :access
      t.timestamps
    end 
  end

  def self.down
    drop_table :custom_forms_plugin_forms
  end
end
