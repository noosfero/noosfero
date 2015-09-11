class OrganizationRatingsBlock < Block
  include RatingsHelper

  def self.description
    _('Organization Ratings')
  end

  def help
    _('This block displays the community ratings.')
  end

  def content(args = {})
    block = self

    proc do
      render(
        :file => 'blocks/organization_ratings_block',
        :locals => {:block => block}
      )
    end
  end

  def limit_number_of_ratings
    env_organization_ratings_config.per_page
  end

  def cacheable?
    false
  end
end
