require_dependency 'person'

class Person

	attr_accessible :lattes_url
	validate :lattes_url_validate?

  def lattes_url_validate?
      valid_url_start = 'http://lattes.cnpq.br/'
      unless self.lattes_url =~ /http:\/\/lattes.cnpq.br\/\d+/  
			errors[:base] << "Sorry, the lattes url is not valid."      	
      end
  end

end