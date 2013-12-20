class AddSelectFieldTypeToCustomFormsPluginFields < ActiveRecord::Migration
  def self.up
    change_table :custom_forms_plugin_fields do |t|
      t.string :select_field_type
    end

    CustomFormsPlugin::Field.find_each do |f|
      if !f.list && !f.multiple
        f.select_field_type = :radio
      elsif !f.list && f.multiple
        f.select_field_type = :check_box
      elsif f.list && !f.multiple
        f.select_field_type = :select
      else
        f.select_field_type = :multiple_select
      end
      f.save!
    end

    change_table :custom_forms_plugin_fields do |t|
      t.remove :multiple, :list
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
