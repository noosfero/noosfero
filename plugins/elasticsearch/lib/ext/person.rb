require_dependency 'person'

require_relative '../../helpers/searchable_model_helper'

class Person

  def self.control_fields
    {
      :visible        => {type: 'boolean'},
      :secret         => { type: :boolean },
      :activities_count => { type: :integer },
      :friends_count    => { type: :integer }
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

  def self.especific_filter
    {
      :more_active  => { label: _("More Active") },
      :more_popular => { label: _("More Popular") }
    }
  end

  def self.get_sort_by  sort_by
    case sort_by
      when "more_active"
        { :activities_count => {order: :desc}}
      when "more_popular"
        { :friends_count => {order: :desc} }
    end
  end

  include SearchableModelHelper
end
