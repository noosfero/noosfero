require_dependency 'event'
require_relative '../elasticsearch_indexed_model'

class Event
  def self.control_fields
    {
      :advertise => {},
      :published => {},
      :created_at => {type: 'date'}
    }
  end
  include ElasticsearchIndexedModel
end
