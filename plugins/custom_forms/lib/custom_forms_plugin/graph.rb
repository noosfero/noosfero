class CustomFormsPlugin::Graph
  # @query_results have the format
  # [
  #   { "data" => { "foo"=> 5, "bla" => 7, "show_as" => "radio"} },
  #   { "data" => { "foo"=> 5, "test" => 7, "show_as" => "check_box"} }
  # ]
  # Each 'data' key on @query_results represents the data that will be used by
  # chartkick lib, to render a graph based on the show_as value.
  #
  # @answers_with_alternative_label have the format
  # {
  #   123 => { "1" => {"foo" : 5}, "2" => {"bla": 7}, "show_as" => "radio"},
  #   124 => { "21" => {"foo" : 2}, "2" => {"test": 15}, "show_as" => "check_box"}
  # }
  #
  # The keys 123 and 124 are the fields ids. In the hash "1" => {"foo" : 5} "1"
  # is the alternative id, "foo" is the alternative label and 5 is the number
  # of users that chose this alternative as answer to it respective field.

  AVAILABLE_FIELDS = %w(check_box radio select multiple_select text)

  def initialize(form)
    @form = form
    self.compute_results
  end

  def compute_results
    results = report()
    field = results[0]["field"]
    graph_data = {"summary" => {}, "data" => {}, "show_as" => "radio", "field" => field}
    results.each do |r|
      r.delete("field")
      graph_data["data"].merge! r
    end
    @query_results = [graph_data]
  end


  def exibition_method(show_as)
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
      .joins('INNER JOIN custom_forms_plugin_alternatives ON '\
             'custom_forms_plugin_alternatives.id::text = custom_forms_plugin_answers.value '\
             'AND custom_forms_plugin_alternatives.field_id = custom_forms_plugin_fields.id')
      .where(custom_forms_plugin_fields: { type: "CustomFormsPlugin::SelectField" })
      .group('custom_forms_plugin_alternatives.label, custom_forms_plugin_fields.name')
      .select('COUNT(custom_forms_plugin_answers.value) as vote_count, '\
              'custom_forms_plugin_alternatives.label as label, '\
              'custom_forms_plugin_fields.name as field_name')
      .map { |r| { r.label => r.vote_count, "field" => r.field_name } }
  end
end
