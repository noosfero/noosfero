class MezuroPlugin::Helpers::ContentViewerHelper
  def self.format_grade(grade)
    sprintf("%.2f", grade.to_f)
  end

  def self.create_periodicity_options
   [["Not Periodically", 0], ["1 day", 1], ["2 days", 2], ["Weekly", 7], ["Biweeky", 15], ["Monthly", 30]]
  end
end
