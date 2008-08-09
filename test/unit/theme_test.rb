require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < ActiveSupport::TestCase
  should 'list system themes' do
    Dir.expects(:glob).with(RAILS_ROOT + '/public/designs/themes/*').returns(
      [
        RAILS_ROOT + '/public/designs/themes/themeone',
        RAILS_ROOT + '/public/designs/themes/themetwo',
        RAILS_ROOT + '/public/designs/themes/themethree'
    ])

    assert_equal ['themeone', 'themetwo', 'themethree'], Theme.system_themes.map(&:id)
  end

  should 'use id as name by default' do
    assert_equal 'the-id', Theme.new('the-id').name
  end

end

