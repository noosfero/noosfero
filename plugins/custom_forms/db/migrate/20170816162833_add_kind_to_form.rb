class AddKindToForm < ActiveRecord::Migration
  def change
    add_column :custom_forms_plugin_forms, :kind, :string, default: 'survey'
  end
end
