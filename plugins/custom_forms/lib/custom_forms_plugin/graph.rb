class CustomFormsPlugin::Graph
  # @query_results have the format
  # [
  #   {
  #     "summary"=>{}, "data"=>{"foo"=>1, "bar"=>1, "teste"=>1},
  #     "show_as"=>"radio", "field"=>"some form field"
  #   }
  # ]
  # Each 'data' key on @query_results represents the data that will be used by
  # chartkick lib, to render a graph based on the show_as value.

  AVAILABLE_FIELDS = %w(check_box radio select multiple_select text)

  def initialize(form)
    @form = form
    self.compute_results
  end

  def compute_results
    results = report()
    field = results[0]["field"]
    show_as = chart_to_show_data(results[0]["show_as"])
    graph_data = {"summary" => {}, "data" => {},
                  "show_as" => show_as , "field" => field}
    results.each do |r|
      r.delete("field")
      r.delete("show_as")
      graph_data["data"].merge! r
    end
    @query_results = [graph_data]
  end


  def chart_to_show_data(show_as)
    return 'pizza' if ["radio", "select"].include?(show_as)
    return 'column' if ["check_box", "multiple_select"].include?(show_as)
    return 'text' if show_as == 'text'
  end

  def query_results
    @query_results
  end

  private

  def report()
    @form.submissions
      .joins(answers: :field)
      .joins('inner join custom_forms_plugin_alternatives ON '\
             'custom_forms_plugin_alternatives.field_id=custom_forms_plugin_fields.id')
      .joins('inner join custom_forms_plugin_form_answers on '\
             'custom_forms_plugin_form_answers.alternative_id=custom_forms_plugin_alternatives.id')
      .group('custom_forms_plugin_alternatives.label, custom_forms_plugin_form_answers.answer_id, custom_forms_plugin_fields.name, custom_forms_plugin_fields.show_as')
      .select('COUNT(custom_forms_plugin_form_answers.answer_id) as answer_count, '\
              'custom_forms_plugin_alternatives.label as label, '\
              'custom_forms_plugin_fields.name as field_name,
              custom_forms_plugin_fields.show_as as show_as')
      .map { |r| { r.label => r.answer_count,
                   "field" => r.field_name, "show_as" => r.show_as } }
  end
end
