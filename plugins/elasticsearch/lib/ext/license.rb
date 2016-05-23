require_dependency 'license.rb'

class License
  def self.control_fields
    %w()
  end

  require_relative '../elasticsearch_helper'
end
