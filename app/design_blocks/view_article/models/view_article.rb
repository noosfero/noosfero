class ViewArticle < Design::Block

  # Define an specific method using the settings hash serialized 
  # variable to keep the value desired by method.
  #
  # EX: 
  #   def max_number_of_element= value
  #     self.settings[:limit_number] = value
  #   end

  def self.description
    'ViewArticle'
  end

  def page
    self.settings[:page]
  end

  def page= value
    self.settings[:page] = value
  end

  def profile
    self.settings[:page]
  end

  def profile= value
    self.settings[:page] = value
  end

end
