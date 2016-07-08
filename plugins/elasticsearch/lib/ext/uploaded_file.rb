require_dependency 'uploaded_file'

require_relative '../../helpers/searchable_model_helper'
require_relative '../../helpers/nested_helper/profile'

class UploadedFile
  def self.control_fields
    {
      :advertise  => {type: :boolean},
      :published  => {type: :boolean},
      :profile   => { type: :nested , hash: NestedProfile.hash }
    }
  end

  def self.should
    [
      { and: [
          { term: { advertise: true }},
          { term: { published: true }}
        ]
      }
    ]
  end

  def self.nested_filter
    [
      NestedProfile::filter
    ]
  end

  include SearchableModelHelper
end
