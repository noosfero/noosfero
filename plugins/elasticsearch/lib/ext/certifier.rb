require_dependency 'certifier'

class Certifier
  def self.control_fields
      %w()
  end

  require_relative '../elasticsearch_helper'
end
