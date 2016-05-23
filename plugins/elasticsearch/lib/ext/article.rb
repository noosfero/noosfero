require_dependency 'article'
require_relative '../elasticsearch_helper'

class Article
  include INDEXED_MODEL

  def self.control_fields
      %w(advertise published).map{ |e| e.to_sym }
  end

  def self.indexable_fields
    SEARCHABLE_FIELDS.keys + self.control_fields 
  end

end
