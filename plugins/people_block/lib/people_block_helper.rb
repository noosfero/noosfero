module PeopleBlockHelper
  def profiles_images_list(profiles)
    size = theme_option(:profile_list_imgs_size) || :minor
    profiles.map { |profile| profile_image_link(profile, size.to_sym) }.join("\n").html_safe
  end

  def set_address_protocol(address)
    !URI.parse(address).scheme ? "http://" + address : address
  end
end
