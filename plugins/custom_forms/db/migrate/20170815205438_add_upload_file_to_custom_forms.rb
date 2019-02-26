class AddUploadFileToCustomForms < ActiveRecord::Migration[5.1]
  def change
    add_reference :custom_forms_plugin_forms , :article, foreign_key: true
  end
end
