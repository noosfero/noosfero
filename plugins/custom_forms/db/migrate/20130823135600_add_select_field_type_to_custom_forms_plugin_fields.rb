class AddSelectFieldTypeToCustomFormsPluginFields < ActiveRecord::Migration
  def self.up
    change_table :custom_forms_plugin_fields do |t|
      t.string :select_field_type
    end

    update("UPDATE custom_forms_plugin_fields SET select_field_type='radio' WHERE list IS FALSE AND multiple IS FALSE")
    update("UPDATE custom_forms_plugin_fields SET select_field_type='check_box' WHERE list IS FALSE AND multiple IS TRUE")
    update("UPDATE custom_forms_plugin_fields SET select_field_type='select' WHERE list IS TRUE AND multiple IS FALSE")
    update("UPDATE custom_forms_plugin_fields SET select_field_type='multiple_select' WHERE list IS TRUE AND multiple IS TRUE")

    change_table :custom_forms_plugin_fields do |t|
      t.remove :multiple, :list
    end
  end

  def self.down
    change_table :custom_forms_plugin_fields do |t|
      t.boolean :multiple
      t.boolean :list
    end

    update("UPDATE custom_forms_plugin_fields SET list=TRUE, multiple=FALSE WHERE select_field_type='radio'")
    update("UPDATE custom_forms_plugin_fields SET list=FALSE, multiople=TRUE WHERE select_field_type='check_box'")
    update("UPDATE custom_forms_plugin_fields SET list=TRUE, multiple=FALSE WHERE select_field_type='select'")
    update("UPDATE custom_forms_plugin_fields SET list=TRUE, multiple=TRUE WHERE select_field_type='multiple_select'")

    change_table :custom_forms_plugin_fields do |t|
      t.remove :select_fields_type
    end
  end
end
