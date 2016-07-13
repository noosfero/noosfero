require_relative './searchable_model/elasticsearch_indexed_model'
require_relative './searchable_model/filter'

module SearchableModelHelper
  def self.included base
    base.send :include, ElasticsearchIndexedModel
    base.send :include, Filter
  end
end
