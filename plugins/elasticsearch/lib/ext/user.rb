require_dependency 'user'

class User
  def self.control_fields
      %w()
  end

  require_relative '../elasticsearch_helper'
end
