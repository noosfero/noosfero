class MezuroPlugin::Helpers::ContentViewerHelper
  def self.format_grade(grade)
    sprintf("%.2f", grade.to_f)
  end
end
