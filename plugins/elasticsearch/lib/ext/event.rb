require_dependency "event"

require_relative "../searchable_model_helper"
require_relative "../nested_helper/profile"

class Event
  # TODO: o filtro é feito de forma diferente do artigo

  def self.control_fields
    {
      advertise: { type: :boolean },
      published: { type: :boolean },
      profile: { type: :nested, hash: NestedProfile.hash }
    }
  end

  def self.should
    [
      { and: [
        { term: { advertise: true } },
        { term: { published: true } }
      ] }
    ]
  end

  def self.nested_filter
    [
      NestedProfile::filter
    ]
  end

  include SearchableModelHelper
end
