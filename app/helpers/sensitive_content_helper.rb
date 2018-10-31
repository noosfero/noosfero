module SensitiveContentHelper

  def sensitive_context_message profile, directory=nil

    directory_name = unless directory.nil?
                        content_tag(:span, directory.name, class: 'publish-page')
                     else
                         _('profile')
                     end

    profile_name = content_tag(:span, profile.name, class: 'publish-profile')

    content_tag :h1 do
        _("You are publishing in ").html_safe + directory_name +
        _(' of ').html_safe + profile_name
    end
  end

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
