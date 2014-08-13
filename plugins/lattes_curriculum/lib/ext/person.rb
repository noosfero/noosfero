require_dependency 'person'

class Person

  attr_accessible :lattes_url, :academic_info_attributes

  has_one :academic_info, :dependent=>:delete

  accepts_nested_attributes_for :academic_info

  def lattes_url
    self.academic_info.nil? ? nil : self.academic_info.lattes_url
  end

  def lattes_url= value
    self.academic_info.lattes_url = value unless self.academic_info.nil?
  end
end
