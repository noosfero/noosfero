class MainBlock < Block

  #This method always return true. It means the current block have to display the result of controller action.
  #It has the same result of put the yield variable on the application layout
  def main?
    true
  end

end
