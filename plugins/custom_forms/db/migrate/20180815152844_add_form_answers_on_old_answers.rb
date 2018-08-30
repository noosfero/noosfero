class AddFormAnswersOnOldAnswers < ActiveRecord::Migration
  require "active_record"
  require "activerecord-import"

  def up
    @connection = ActiveRecord::Base.connection
    values = @connection.exec_query(
      "SELECT a.id as answer_id, al.id as alternative_id FROM custom_forms_plugin_answers AS a
      INNER JOIN custom_forms_plugin_fields AS f ON a.field_id = f.id
      LEFT JOIN custom_forms_plugin_form_answers AS fa ON fa.answer_id = a.id
      INNER JOIN custom_forms_plugin_alternatives AS al ON al.id IN
      (SELECT regexp_split_to_table(a.value, ',')::int) WHERE fa.id IS NULL 
      AND f.type = 'CustomFormsPlugin::SelectField';"
    )

    columns = ["answer_id", "alternative_id"]
    CustomFormsPlugin::FormAnswer.import! columns, values.rows
  end

  def down
    fields = CustomFormsPlugin::Field.where(type: "CustomFormsPlugin::SelectField")
    answers_ids = CustomFormsPlugin::FormAnswer.all.map(&:answer_id)
    answers = CustomFormsPlugin::Answer.where("id IN (?)", answers_ids)

    CustomFormsPlugin::FormAnswer.delete_all
    answers.each do |answer|
      answer.form_answers = []
      answer.save!
    end
  end
end
