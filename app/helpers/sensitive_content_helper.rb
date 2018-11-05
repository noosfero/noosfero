module SensitiveContentHelper

  def sensitive_context_message sensitive_context, display_directory=true

    directory = sensitive_context.directory
    profile = sensitive_context.profile

    directory_name = if !directory.nil? && display_directory
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
    if GenericContext.publish_permission?(profile_viewed, current_user)
      profile_viewed.identifier
    else
      current_user.identifier
    end
  end

  def directory_option directory
    content_tag :li, class: "bigicon-#{directory.icon_name}" do
      content_tag(:h3, directory.name) +
      content_tag(:div, directory.abstract, class: 'description')
    end
  end

end
