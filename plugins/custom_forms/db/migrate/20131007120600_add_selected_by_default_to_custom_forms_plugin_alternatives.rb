class AddSelectedByDefaultToCustomFormsPluginAlternatives < ActiveRecord::Migration
  def self.up
    add_column :custom_forms_plugin_alternatives, :selected_by_default, :boolean, :null => false, :default => false
    CustomFormsPlugin::Field.find_each do |f|
      f.alternatives.each do |a|
        a.update_attribute(:selected_by_default, true) if a.label == f.default_value
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
