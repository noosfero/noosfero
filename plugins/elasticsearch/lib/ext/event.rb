require_dependency 'event'
require_relative '../elasticsearch_indexed_model'

class Event
  include ElasticsearchIndexedModel

  def self.control_fields
    [
      :advertise,
      :published,
    ]
  end
end
