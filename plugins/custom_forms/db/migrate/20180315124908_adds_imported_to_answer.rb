class AddsImportedToAnswer < ActiveRecord::Migration
  def change
    add_column :custom_forms_plugin_answers, :imported, :boolean,
               default: false
  end
end
