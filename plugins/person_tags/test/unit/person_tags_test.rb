require 'test_helper'

class PersonTagsPluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(PersonTagsPlugin)
  end

  should 'have tags' do
    person = create_user('person').person
    assert_equal [], person.tags
    person.tag_list.add('linux')
    assert_equal ['linux'], person.tag_list
  end
end
