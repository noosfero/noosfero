class CreateCustomFormsPluginSubmissions < ActiveRecord::Migration
  def self.up
    create_table :custom_forms_plugin_submissions do |t|
      t.string :author_name
      t.string :author_email
      t.references :profile
      t.references :form
      t.timestamps
    end
  end

  def self.down
    drop_table :custom_forms_plugin_submissions
  end
end
