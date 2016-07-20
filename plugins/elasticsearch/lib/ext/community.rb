require_dependency 'community'
require_relative '../searchable_model_helper'

class Community

  def self.control_fields
    {
      :secret           => { type: :boolean },
      :visible          => { type: :boolean },
      :activities_count => { type: :integer },
      :members_count    => { type: :integer }
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

  def self.specific_sort
    {
      :more_active  => _("More active"),
      :more_popular => _("More popular")
    }
  end

  def self.get_sort_by  sort_by=""
    case sort_by
      when :more_active
        { :activities_count => {order: :desc}}
      when :more_popular
        { :members_count => {order: :desc}}
    end
  end

  include SearchableModelHelper
end
