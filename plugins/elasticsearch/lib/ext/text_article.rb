# REQUIRE TO LOAD DESCENDANTS FROM TEXT_ARTICLE
require_dependency 'raw_html_article'
require_dependency 'tiny_mce_article'
require_dependency 'text_article'

require_relative '../../helpers/searchable_model_helper'
require_relative '../../helpers/nested_helper/profile'

class TextArticle

  def self.control_fields
    {
      :advertise      => { type: :boolean },
      :published      => { type: 'boolean'},
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

  def self.especific_sort
    {
      :more_popular   => { label: _("More Viewed") },
      :more_comments  => { label: _("More Commented") }
    }
  end

  def self.get_sort_by  sort_by
    case sort_by
      when "more_popular"
        { :hits => {order: :desc} }
      when "more_comments"
        { :comments_count => {order: :desc}}
    end
  end

  include SearchableModelHelper
end
