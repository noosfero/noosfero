class AddUploadFileToCustomForms < ActiveRecord::Migration
  def change
    add_reference :custom_forms_plugin_forms , :article, foreign_key: true
  end
end
