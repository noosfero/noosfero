class Profile
  def inspect
    "#{self.class.name}/#{id}/#{identifier}"
  end
end

