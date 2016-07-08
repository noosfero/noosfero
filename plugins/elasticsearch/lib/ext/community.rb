require_dependency 'community'
require_relative '../../helpers/searchable_model_helper'

class Community

  def self.control_fields
    {
      :secret           => { type: :boolean },
      :visible          => { type: :boolean },
    }
  end

  def self.should
    [
      { and:
        [
          {term: { :secret => false }},
          {term: { :visible => true }}
        ]
      }
    ]
  end

  include SearchableModelHelper
end
