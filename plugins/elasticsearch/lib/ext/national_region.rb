require_dependency 'national_region'

class NationalRegion
  def self.control_fields
      %w()
  end

  require_relative '../elasticsearch_helper'
end
