class AcademicInfo < ActiveRecord::Base

	belongs_to :person

	attr_accessible :lattes_url
  validate :lattes_url_validate?

  def lattes_url_validate?
    valid_url_start = 'http://lattes.cnpq.br/'
    unless self.lattes_url.blank? || self.lattes_url =~ /http:\/\/lattes.cnpq.br\/\d+/ 
      self.errors.add(:lattes_url, _("Sorry, the lattes url is not valid."))
    end
  end
end
