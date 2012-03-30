class MezuroPlugin::Helpers::ContentViewerHelper
  def self.format_grade(grade)
    grade.slice(/[0-9]+\.[0-9]{1,2}/)
  end
end
