require File.expand_path(File.dirname(__FILE__) +  "/../../../app/models/profile")

class Profile
  def inspect
    "#{self.class.name}/#{id}/#{identifier}"
  end
end

