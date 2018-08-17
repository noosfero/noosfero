class AddFormAnswersOnOldAnswers < ActiveRecord::Migration
  def up
    answers_without_form_answer = CustomFormsPlugin::Answer.includes(:form_answers)
                                  .where(custom_forms_plugin_form_answers: {id: nil})
    select_answers_without_form_answer = answers_without_form_answer.select {|a| a.field.type == "CustomFormsPlugin::SelectField"}

    select_answers_without_form_answer.each do |answer|
      alternatives_ids = answer.attributes['value']
      alternatives = CustomFormsPlugin::Alternative.where("id IN (?)", alternatives_ids)
      alternatives.each do |alternative|
        form_answer = CustomFormsPlugin::FormAnswer.create!(answer_id: answer.id, alternative_id: alternative.id)
        answer.form_answers << form_answer
        answer.save!
      end
    end
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
