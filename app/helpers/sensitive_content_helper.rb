module SensitiveContentHelper
  def profile_to_publish(current_user, profile_viewed)
    if GenericContext.publish_permission?(profile_viewed, current_user)
      profile_viewed.identifier
    else
      current_user.identifier
    end
  end

  def alternative_context(context, page = nil)
    if alternative_contexts.has_key?(context.to_sym)
      alternative_contexts[context.to_sym]
    elsif !page.nil? && alternative_contexts.has_key?(page.model_name.param_key.to_sym)
      alternative_contexts[page.model_name.param_key.to_sym]
    else
      nil
    end
  end

  def sensitive_context_message(sensitive_context, display_directory = true)
    directory = sensitive_context.directory
    profile = sensitive_context.profile

    directory_name = if !directory.nil? && display_directory
                       content_tag(:span, directory.name, class: "publish-page")
                     else
                       _("profile")
                     end

    profile_name = content_tag(:span, profile.name, class: "publish-profile")

    content_tag :h1 do
      _("You are publishing in ").html_safe + directory_name +
        _(" of ").html_safe + profile_name
    end
  end

  def directory_option(directory)
    content_tag :li, class: "bigicon-#{directory.icon_name}" do
      content_tag(:h3, directory.name) +
        content_tag(:div, directory.abstract, class: "description")
    end
  end

  def select_directory_button(sensitive_content)
    modal_button(:folder, _("Post to another directory"),
                 url_for(controller: "cms", action: "sensitive_content",
                         profile: sensitive_content.profile.identifier,
                         page: sensitive_content.directory.try(:id),
                         select_directory: true,
                         alternative_context: sensitive_content.alternative_context),
                 class: "option-folder add-sensitive-history")
  end

  def select_profile_button(sensitive_content)
    modal_button(:folder, _("Post to another profile"),
                 url_for(controller: "cms", action: "select_profile",
                         profile: sensitive_content.profile.identifier,
                         page: sensitive_content.directory.try(:id),
                         alternative_context: sensitive_content.alternative_context),
                 class: "option-profile add-sensitive-history")
  end

  def sensitive_back_button(not_back = false)
    if not_back
      button :none, "", "#", class: "button option-not-back"
    else
      button :back, _("Back"), "#", class: "button option-back"
    end
  end

  def select_item(title, image)
    content_tag :li do
      content_tag :div, class: "image-profile" do
        image + content_tag(:h3, title)
      end
    end
  end

  private

    def alternative_contexts
      {
        events: "Agenda",
        event: "Agenda"
      }
    end

    def sensitive_path_to_parents(sensitive_content)
      if sensitive_content.directory
        directory = sensitive_content.directory
        path = link_to(directory.profile.name, sensitive_url_to(sensitive_content.profile),
                       class: "path-to-parent open-modal add-sensitive-history")
        parents = directory.hierarchy.select { |parent| parent != directory }
        parents.each do |parent|
          path += link_to(font_awesome(:angle_right, parent.name),
                          sensitive_url_to(directory.profile, parent),
                          class: "path-to-parent open-modal add-sensitive-history")
        end
        path += link_to(font_awesome(:angle_right, directory.name),
                        "#", class: "path-to-parent")
      else
        path = link_to(sensitive_content.profile.name, "#", class: "path-to-parent")
      end
      content_tag(:div, path, class: "path-to-parents")
    end

    def sensitive_url_to(profile, directory = nil, alternative_context = nil)
      url_for(controller: "cms", action: "sensitive_content",
              profile: profile.identifier,
              page: directory,
              alternative_context: alternative_context)
    end
end
