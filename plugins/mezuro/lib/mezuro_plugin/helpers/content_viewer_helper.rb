class MezuroPlugin::Helpers::ContentViewerHelper

  MAX_NUMBER_OF_LABELS = 5

  def self.format_grade(grade)
    sprintf("%.2f", grade.to_f)
  end

  def self.create_periodicity_options
   [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweeky", 15], ["Monthly", 30]]
  end

  def self.create_license_options
   options = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/licenses.yaml")
   options = options.split(";")
   formated_options = []
   options.each { |option| formated_options << [option, option] }
   formated_options
  end

  def self.generate_chart(score_history)
    values = []
    labels = []
    score_history.each do |score_data|
      values << score_data.first
      labels << score_data.last
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

  def self.get_periodicity_option(index)
    options = [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweeky", 15], ["Monthly", 30]]
    selected_option = options.find { |option| option.last == index.to_i }
    selected_option.first
  end

  def self.format_name(metric_result)
    metric_result.metric.name.delete("() ")
  end

  def self.get_license_option(selected)
    options = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/licenses.yaml")
    options.split(";")
    selected_option = options.find { |license| license == selected }
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
