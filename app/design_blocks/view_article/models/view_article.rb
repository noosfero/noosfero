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

  def article_id
    self.settings[:article_id]
  end
  
  def article_id= value
    self.settings[:article_id] = value
  end

  def article
    Article.find(article_id) if article_id
  end

end
