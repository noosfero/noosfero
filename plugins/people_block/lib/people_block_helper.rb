module PeopleBlockHelper
  def profiles_images_list(profiles)
    profiles.map { |profile| profile_image_link(profile, :minor) }.join("\n")
  end

  def set_address_protocol(address)
    !URI.parse(address).scheme ? 'http://'+address : address
  end
end
