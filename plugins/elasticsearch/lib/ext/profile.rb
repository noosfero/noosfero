require_dependency 'profile'

class Profile
  def self.control_fields
    %w( visible public_profile )
  end

  require_relative '../elasticsearch_helper'
end
