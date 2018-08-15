class AddFormAnswersOnOldAnswers < ActiveRecord::Migration
  def up
    fields = CustomFormsPlugin::Field.where(type: "CustomFormsPlugin::SelectField")
    all_answers = fields.map(&:answers).flatten
    form_answers_answers = CustomFormsPlugin::FormAnswer.all.map(&:answer_id)
    answers_without_form_answer_ids = all_answers.map(&:id) - form_answers_answers
    answers_without_form_answer = CustomFormsPlugin::Answer.where("id IN (?)", answers_without_form_answer_ids)

    answers_without_form_answer.each do |answer|
      answer.alternatives.each do |alternative|
        form_answer = CustomFormsPlugin::FormAnswer.create(answer_id: answer.id, alternative_id: alternative.id)
        answer.form_answers << form_answer
        answer.save!
      end
    end
  end

  def down
    fields = CustomFormsPlugin::Field.where(type: "CustomFormsPlugin::SelectField")
    answers_ids = CustomFormsPlugin::FormAnswer.all.map(&:answer_id)
    answers = CustomFormsPlugin::Answer.where("id IN (?)", answers_ids)

    answers.each do |answer|
      answer.form_answers = []
      answer.save!
    end
  end
end
