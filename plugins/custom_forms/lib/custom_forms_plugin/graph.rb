class CustomFormsPlugin::Graph

  # Other custom_forms fields, should be added here. A method <field>_answers
  # also will have to be implemented.
  AVAILABLE_FIELDS = ["check_box", "radio", "text"]

  def initialize(form)
    @answers_with_alternative_label = []
    @query_results = []
    @form = form
    self.compute_results
  end

  def compute_results
    @form.fields.includes(:alternatives).each do |field|
      answer_and_label = merge_field_answer_and_label(field)
      unless answer_and_label.empty?
        @answers_with_alternative_label << answer_and_label
      end
    end
    answers_by_submissions(@form.submissions.includes(:answers))
    format_data_to_generate_graph
  end

  # @query_results have the format
  # [{ "foo"=> 15, "bla" => 8, "show_as" => "radio"}].  Each position
  # on the list represents the data that will be used by
  # chartkick lib, to render a graph based on the show_as value.
  def query_results
    @query_results
  end

  private

  def merge_field_answer_and_label(field)
    return {} unless AVAILABLE_FIELDS.include? field.show_as
    alternatives = field.alternatives
    answer_and_label = {}
    if alternatives.empty?
      text_answers = {"text_answers" => {"answers" => [], "users" => []},
                      "show_as" => {"show_as" => field.show_as}}
      answer_and_label.merge!(text_answers)
      return answer_and_label
    end

    alternatives.map do |alternative|
      answer_and_label.merge!({alternative.id.to_s => {alternative.label => 0}})
    end
    answer_and_label.merge!({"show_as" => {"show_as" => field.show_as}})
    answer_and_label
  end

  def format_data_to_generate_graph
    return [] if @answers_with_alternative_label.empty?
    @answers_with_alternative_label.each do |answers|
      merged_answers = {}
      answers.each do |key, value|
        merged_answers.merge!(value)
      end
      @query_results << merged_answers
    end
    @query_results
  end

  def answers_by_submissions submissions
    return [] if @answers_with_alternative_label.empty?
    submissions.each do |submission|
      answers = submission.answers
      answers.each_with_index do |answer, index|
        answer_with_alternative_label = @answers_with_alternative_label[index]
        show_as = answer_with_alternative_label["show_as"]["show_as"]
        if AVAILABLE_FIELDS.include? show_as
          value = answer.value
          self.send(show_as + "_answers", index, value)
        end
      end
    end
  end

  def check_box_answers(index, value)
    list_of_answers = value.split(",")
    list_of_answers.each do |answer|
      alternative_and_sum_of_answers = @answers_with_alternative_label[index][answer]
      alternative = alternative_and_sum_of_answers.keys.first
      @answers_with_alternative_label[index][answer][alternative] += 1
    end
  end

  def radio_answers(index, answer)
      alternative_and_sum_of_answers = @answers_with_alternative_label[index][answer]
      alternative = alternative_and_sum_of_answers.keys.first
      @answers_with_alternative_label[index][answer][alternative] += 1
  end

  def text_answers(index, answer)
      @answers_with_alternative_label[index]["text_answers"]["answers"] << answer
      user = @form.profile.name
      @answers_with_alternative_label[index]["text_answers"]["users"] << user
  end
end
