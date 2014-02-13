class CreateCustomFormsPluginAlternatives < ActiveRecord::Migration
  def self.up
    create_table :custom_forms_plugin_alternatives do |t|
      t.string :label
      t.references :field
    end
  end

  def self.down
    drop_table :custom_forms_plugin_alternatives
  end
end
