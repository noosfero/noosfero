require File.dirname(__FILE__) + '/../test_helper'

class LayoutTemplateTest < ActiveSupport::TestCase

  should 'read configuration' do
    YAML.expects(:load_file).with(RAILS_ROOT + '/public/designs/templates/default/config.yml').returns({'number_of_boxes' => 3, 'description' => 'my description', 'title' => 'my title'})
    t = LayoutTemplate.find('default')
    assert_equal 3, t.number_of_boxes
    assert_equal 'my description', t.description
    assert_equal 'my title', t.title
  end

  should 'list all' do
    Dir.expects(:glob).with(RAILS_ROOT + '/public/designs/templates/*').returns([RAILS_ROOT + '/public/designs/templates/one', RAILS_ROOT + '/public/designs/templates/two'])
    YAML.expects(:load_file).with(RAILS_ROOT + '/public/designs/templates/one/config.yml').returns({})
    YAML.expects(:load_file).with(RAILS_ROOT + '/public/designs/templates/two/config.yml').returns({})

    all = LayoutTemplate.all
    assert_equivalent [ 'one', 'two' ], all.map(&:id)
  end
  
end
