class CreateFormAnswerModel < ActiveRecord::Migration[5.1]
  def up
    create_table :custom_forms_plugin_form_answers do |t|
      t.belongs_to :alternative, index: true
      t.belongs_to :answer, index: true
    end
  end

  def down
    drop_table :custom_forms_plugin_form_answers
  end
end
