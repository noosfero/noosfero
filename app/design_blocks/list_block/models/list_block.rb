class ListBlock < Design::Block

  # Define an specific method using the settings hash serialized 
  # variable to keep the value desired by method.
  #
  # EX: 
  #   def max_number_of_element= value
  #     self.settings[:limit_number] = value
  #   end

  def self.description
    _('List Block')
  end
  
  def limit_number= value
    self.settings[:limit_number] = value.to_i == 0 ? nil : value.to_i
  end

  def limit_number
    self.settings[:limit_number]
  end

  def people
    Person.find(:all, :limit => limit_number)
  end

end
