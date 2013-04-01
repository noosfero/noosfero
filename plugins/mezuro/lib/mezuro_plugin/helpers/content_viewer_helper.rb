class MezuroPlugin::Helpers::ContentViewerHelper

  MAX_NUMBER_OF_LABELS = 5

  def self.format_grade(grade)
    sprintf("%.2f", grade.to_f)
  end

  def self.periodicity_options
    [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweekly", 15], ["Monthly", 30]]
  end

  def self.periodicity_option(periodicity)
    periodicity_options.select {|x| x.last == periodicity}.first.first
  end

  def self.license_options
   options = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/licenses.yml")
   options = options.split("; ")
   options
  end

  def self.generate_chart(score_history)
    values = []
    labels = []
    score_history.each do |score_data|
      values << score_data.result
      labels << score_data.date
    end
    labels = discretize_array labels
    Gchart.line(
                :title_color => 'FF0000',
                :size => '600x180', 
                :bg => {:color => 'efefef', :type => 'stripes'},
                :line_colors => 'c4a000',
                :data => values,
                :labels => labels,
                :axis_with_labels => ['y','x'],
                :max_value => values.max,
                :min_value => values.min
                )
  end

  def self.format_name(metric_configuration_snapshot)
    metric_configuration_snapshot.metric.name.delete("() ")
  end
  
  def self.format_time(miliseconds)
    seconds = miliseconds/1000
    MezuroPluginModuleResultController.helpers.distance_of_time_in_words(0, seconds, include_seconds = true)
  end

  def self.aggregation_options
    [["Average","AVERAGE"], ["Median", "MEDIAN"], ["Maximum", "MAXIMUM"], ["Minimum", "MINIMUM"],
      ["Count", "COUNT"], ["Standard Deviation", "STANDARD_DEVIATION"]]
  end

  def self.scope_options
    [["Software", "SOFTWARE"], ["Package", "PACKAGE"], ["Class", "CLASS"], ["Method", "METHOD"]]
  end

  private

  def self.discretize_array(array)
    if array.size > MAX_NUMBER_OF_LABELS
      range_array.map { |i| discrete_element(array, i)}
    else
      array
    end
  end

  def self.range_array
    (0..(MAX_NUMBER_OF_LABELS - 1)).to_a
  end

  def self.discrete_element(array, i)
    array[(i*(array.size - 1))/(MAX_NUMBER_OF_LABELS - 1)]
  end

end
