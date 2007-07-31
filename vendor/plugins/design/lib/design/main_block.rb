module Design

  # Block subclass to represent blocks that must contain the main content, i.e.
  # the result of the controller action, or yet, the value you would get by
  # calling +yield+ inside a regular view.
  class MainBlock < Block

    # always returns true
    def main?
      true
    end
  
  end

end
