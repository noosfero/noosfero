class AddKindToForm < ActiveRecord::Migration[5.1]
  def change
    add_column :custom_forms_plugin_forms, :kind, :string, default: "survey"
  end
end
