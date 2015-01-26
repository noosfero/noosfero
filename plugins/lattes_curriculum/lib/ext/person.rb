require_dependency 'person'

class Person

  attr_accessible :lattes_url, :academic_info_attributes

  has_one :academic_info

  after_destroy do |person|
    if !person.environment.nil? &&
person.environment.plugin_enabled?(LattesCurriculumPlugin) &&
!person.academic_info.nil?
      person.academic_info.destroy
    end
  end

  accepts_nested_attributes_for :academic_info

  def lattes_url
    if self.environment && self.environment.plugin_enabled?(LattesCurriculumPlugin)
      self.academic_info.nil? ? nil : self.academic_info.lattes_url
    end
  end

  def lattes_url= value
    if self.environment && self.environment.plugin_enabled?(LattesCurriculumPlugin)
      self.academic_info.lattes_url = value unless self.academic_info.nil?
    end
  end

  FIELDS << "lattes_url"
end
