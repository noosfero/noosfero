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

  def elements_types
    ['Person', 'Enterprise']
  end

  def element_type
    self.settings[:element_type]
  end

  def element_type= value
    return nil unless elements_types.include?(value)
    self.settings[:element_type] = value
  end

  def elements
    return nil unless element_type
    self.element_type.constantize.find(:all, :limit => limit_number)
  end

  def view
    return 'nothing' unless element_type
    element_type.to_s.underscore
  end

  def display_block
    'true'
  end

  def display_header
    'true'
  end

end
