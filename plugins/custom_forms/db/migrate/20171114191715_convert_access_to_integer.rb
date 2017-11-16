class ConvertAccessToInteger < ActiveRecord::Migration
  def up
    add_column :custom_forms_plugin_forms, :new_access, :integer, default: 0

    execute("UPDATE custom_forms_plugin_forms SET new_access = 1 WHERE access LIKE '%logged%'")
    execute("UPDATE custom_forms_plugin_forms SET new_access = 2 WHERE access LIKE '%associated%'")

    remove_column :custom_forms_plugin_forms, :access
    rename_column :custom_forms_plugin_forms, :new_access, :access
  end

  def down
    add_column :custom_forms_plugin_forms, :new_access, :string

    remove_column :custom_forms_plugin_forms, :access
    rename_column :custom_forms_plugin_forms, :new_access, :access
  end
end
