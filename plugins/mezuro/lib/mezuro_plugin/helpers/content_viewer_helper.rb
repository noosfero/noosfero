require 'googlecharts'

class MezuroPlugin::Helpers::ContentViewerHelper
  def self.format_grade(grade)
    sprintf("%.2f", grade.to_f)
  end

  def self.create_periodicity_options
   [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweeky", 15], ["Monthly", 30]]
  end
  
  def self.generate_chart(values)
    Gchart.line(  
                :title_color => 'FF0000',
                :size => '600x180', 
                :bg => {:color => 'efefef', :type => 'stripes'},
                :line_colors => 'c4a000',
                :data => values,
                :axis_with_labels => 'y')
  end
end
