class AverageRatingBlock < Block
  include RatingsHelper

  def self.description
    _('Organization Average Rating')
  end

  def help
    _('This block displays the organization average rating.')
  end

  def content(args = {})
    profile_identifier = self.owner.identifier
    average_rating = OrganizationRating.average_rating self.owner.id

    proc do
      render(
        :file => 'blocks/display_organization_average_rating',
        :locals => {
          :profile_identifier => profile_identifier,
          :average_rating => average_rating
        }
      )
    end
  end

  def cacheable?
    false
  end
end
