class Community < Profile

  def name=(value)
    super(value)
    self.identifier = value.to_slug
  end

end
