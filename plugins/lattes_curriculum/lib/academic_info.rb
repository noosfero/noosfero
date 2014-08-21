class AcademicInfo < ActiveRecord::Base

  belongs_to :person

  attr_accessible :lattes_url
  validate :lattes_url_validate?

  def lattes_url_validate?
    unless AcademicInfo.matches?(self.lattes_url)
      self.errors.add(:lattes_url, _(" is invalid."))
    end
  end

  def self.matches?(info)
    lattes = nil
    if info.class == String
      lattes = info
    elsif info.class == Hash
      lattes = info[:lattes_url]
    end
    return lattes.blank? || lattes =~ /^http:\/\/lattes.cnpq.br\/\d+$/
  end
end
