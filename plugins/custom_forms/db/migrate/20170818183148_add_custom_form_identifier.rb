class AddCustomFormIdentifier < ActiveRecord::Migration
  def change
    add_column :custom_forms_plugin_forms, :identifier,  :string
  end
end
