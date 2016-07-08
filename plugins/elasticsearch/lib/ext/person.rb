require_dependency 'person'

require_relative '../../helpers/searchable_model_helper'

class Person

  def self.control_fields
    {
      :visible        => {type: 'boolean'},
      :secret         => { type: :boolean },
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
