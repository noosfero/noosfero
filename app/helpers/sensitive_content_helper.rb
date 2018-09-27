module SensitiveContentHelper

  # def profile_to_publish current_user, profile_viewed
  #   if profile_viewed.present?
  #       if current_user.has_permission?('post_content', profile_viewed) ||
  #           current_user.has_permission?('publish_content', profile_viewed)
  #           if profile_viewed.organization?
  #               profile_viewed.identifier
  #           else
  #               current_user.identifier
  #           end
  #       else
  #           current_user.identifier
  #       end
  #   else
  #       current_user.identifier
  #   end
  # end

  def profile_to_publish current_user, profile_viewed
    if sensitive_publish_permission?(current_user, profile_viewed)
      profile_viewed.identifier
    else
      current_user.identifier
    end
  end

  private

  def sensitive_publish_permission? user, profile
    profile.present? && user.has_permission?('post_content', profile) &&
      profile.organization?
  end
end
