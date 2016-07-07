require_dependency 'community'
require_relative '../elasticsearch_indexed_model'

class Community

  def self.control_fields
    {
      :secret         => { type: :boolean },
      :visible        => { type: :boolean },
    }
  end

  # community visible
  def self.should_and
    [
      {term: { :secret => false }},
      {term: { :visible => true }}
    ]
  end


  include ElasticsearchIndexedModel

end
