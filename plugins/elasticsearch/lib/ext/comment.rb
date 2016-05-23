require_dependency 'comment'

class Comment
  def self.control_fields
      %w()
  end

  require_relative '../elasticsearch_helper'
end
