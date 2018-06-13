require 'test_helper'

class StoaPluginTest < ActiveSupport::TestCase
  should 'display invite control panel button only to users with usp_id' do
    person_with_usp_id = fast_create(Person, :usp_id => 99999999)
    person_without_usp_id = fast_create(Person)
    profile = fast_create(Profile)

    refute StoaPlugin::ControlPanel::InviteFriends.display?(nil, profile)
    refute StoaPlugin::ControlPanel::InviteFriends.display?(person_without_usp_id, person_without_usp_id)
    refute StoaPlugin::ControlPanel::InviteFriends.display?(person_with_usp_id, profile)
    assert StoaPlugin::ControlPanel::InviteFriends.display?(person_with_usp_id, person_with_usp_id)
  end
end
