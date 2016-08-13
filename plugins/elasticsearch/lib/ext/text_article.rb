# REQUIRE TO LOAD DESCENDANTS FROM TEXT_ARTICLE
require_dependency 'text_article'

require_relative '../searchable_model_helper'
require_relative '../nested_helper/profile'

class TextArticle

  def self.control_fields
    {
      :advertise      => { type: :boolean },
      :published      => { type: :boolean },
      :comments_count => { type: :integer },
      :hits           => { type: :integer },
      :profile        => { type: :nested , hash: NestedProfile.hash }
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

  def self.specific_sort
    {
      :more_popular   => _("More viewed"),
      :more_comments  => _("Most commented")
    }
  end

  def self.get_sort_by  sort_by=""
    case sort_by
      when :more_popular
        { :hits => {order: :desc} }
      when :more_comments
        { :comments_count => {order: :desc}}
    end
  end

  include SearchableModelHelper
end
