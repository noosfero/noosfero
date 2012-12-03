class CreateCustomFormsPluginAnswers < ActiveRecord::Migration
  def self.up
    create_table :custom_forms_plugin_answers do |t|
      t.text :value
      t.references :field
      t.references :submission
    end
  end

  def self.down
    drop_table :custom_forms_plugin_answers
  end
end
