require_dependency 'scrap'

class Scrap
  def self.control_fields
      %w(advertise published)
  end

  require_relative '../elasticsearch_helper'
end
