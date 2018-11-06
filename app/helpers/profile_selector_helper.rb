module ProfileSelectorHelper

  def profile_selector profiles_container

    search_field = text_field_tag(:profile_selector_search, nil,
                          placeholder: _('Filter profiles by name'),
                          id: 'profile-selector-search')

    selector_container = content_tag :div, profiles_container,
      class: 'profile-selector-container scrollbar'

    content_tag(:div, search_field + selector_container,
                class: 'profile-selector')
  end

  private

  def checkbox_entry_to_profile_selector profiles, profile_infos=nil
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

  def modal_url_entry_to_profile_selector profiles, url_options={}
    profiles.collect do |profile|
      if url_options.empty?
        url = profile.url
      else
        url = url_for(url_options.merge(:profile => profile.identifier))
      end

      link_to url, class: ' profile-selector-entry open-modal' do
        name = content_tag(:span, profile.name, class: 'profile-name') +
               content_tag(:span, profile.identifier, class: 'profile-identifier')

        image_tag(profile_icon(profile)) +
        content_tag(:div, name, class: 'profile-selector-entry-info')
      end
    end.join.html_safe
  end

end
