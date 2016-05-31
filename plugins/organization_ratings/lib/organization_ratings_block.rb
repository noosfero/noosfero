class OrganizationRatingsBlock < Block
  include RatingsHelper

  def self.description
    _('Organization Ratings')
  end

  def help
    _('This block displays the organization ratings.')
  end

  def limit_number_of_ratings
    env_organization_ratings_config.per_page
  end

  def ratings_on_initial_page
    env_organization_ratings_config.ratings_on_initial_page
  end

  def cacheable?
    false
  end
end
