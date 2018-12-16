class AddsImportedToAnswer < ActiveRecord::Migration[5.1]
  def change
    add_column :custom_forms_plugin_answers, :imported, :boolean,
               default: false
  end
end
