class AddAccessLevelToForm < ActiveRecord::Migration[5.1]
  def self.up
    add_column :custom_forms_plugin_forms, :access_result_options, :string,
               default: "public"
  end

  def self.down
    remove_column :custom_forms_plugin_forms, :access_result_options
  end
end
