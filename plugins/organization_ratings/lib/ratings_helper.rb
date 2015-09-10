module RatingsHelper

  def env_organization_ratings_config
    OrganizationRatingsConfig.instance
  end

  def get_ratings (profile_id)
    order_options = env_organization_ratings_config.order_options
    if env_organization_ratings_config.order.downcase == order_options[:recent]
      ratings = OrganizationRating.where(organization_id: profile_id).order("value DESC")
    else
      ratings = OrganizationRating.where(organization_id: profile_id).order("created_at DESC")
    end
  end
end