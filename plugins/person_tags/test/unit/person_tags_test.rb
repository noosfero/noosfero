require 'test_helper'

class PersonTagsPluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(PersonTagsPlugin)
  end

  should 'have interests' do
    person = create_user('person').person
    assert_equal [], person.interests
    person.interest_list.add('linux')
    assert_equal ['linux'], person.interest_list
  end
end
