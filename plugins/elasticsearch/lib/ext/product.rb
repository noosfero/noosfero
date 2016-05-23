require_dependency 'product'

class Product
  def self.control_fields
     %w() 
  end

  require_relative '../elasticsearch_helper'
end
