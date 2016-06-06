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

  def status_message_for(person, rating)
    if person.present? && rating.display_full_info_to?(person)
      if(rating.task_status == Task::Status::ACTIVE)
        content_tag(:p, _("Report waiting for approval"), class: "moderation-msg")
      elsif(rating.task_status == Task::Status::CANCELLED)
        content_tag(:p, _("Report rejected"), class: "rejected-msg")
      end
    end
  end
end
