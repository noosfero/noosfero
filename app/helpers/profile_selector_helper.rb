module ProfileSelectorHelper

  def profile_selector profiles, profile_infos = nil

    search_field = text_field_tag(:profile_selector_search, nil,
                          placeholder: _('Filter profiles by name'),
                          id: 'profile-selector-search')

    selector_container = content_tag :div,
            class: 'profile-selector-container scrollbar' do

      profiles.collect do |profile|

        content_tag :label, class: 'profile-selector-entry' do

          name = content_tag(:span, profile.name, class: 'profile-name') +
                 content_tag(:span, profile.identifier, class: 'profile-identifier')

          check_box_tag('profile_ids[]', profile.id) +
          image_tag(profile_icon(profile)) +
          content_tag(:div, name + profile_infos,
                  class: 'profile-selector-entry-info')
        end
      end.join.html_safe
    end

    content_tag(:div, search_field + selector_container,
                class: 'profile-selector')
  end

end
