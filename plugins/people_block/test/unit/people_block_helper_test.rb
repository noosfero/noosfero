require 'test_helper'

class PeopleBlockHelperTest < ActionView::TestCase
  include PeopleBlockHelper

  should 'list profiles as images links' do
    owner = fast_create(Environment)
    profiles = [
      fast_create(Person, :environment_id => owner.id),
      fast_create(Person, :environment_id => owner.id),
      fast_create(Person, :environment_id => owner.id)
    ]
    link_html = "<a href=#><img src='' /></a>"

    profiles.each do |profile|
      expects(:profile_image_link).with(profile, :minor).returns(link_html)
    end

    list = profiles_images_list(profiles)

    assert_equal list, ([link_html]*profiles.count).join("\n")
  end

  should 'prepend the protocol to urls missing it' do
    address = 'noosfero.org'

    assert_equal set_address_protocol(address), 'http://'+address
  end

  should 'leave urls already with protocol unchanged' do
    address = 'http://noosfero.org'
    ssl_address = 'https://noosfero.org'

    assert_equal set_address_protocol(address), address
    assert_equal set_address_protocol(ssl_address), ssl_address
  end
end