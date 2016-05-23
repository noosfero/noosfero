require_dependency 'category'

class Category
  def self.control_fields
      %w()
  end

  require_relative '../elasticsearch_helper'
end
