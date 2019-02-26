require_relative "../test_helper"

class LayoutTemplateTest < ActiveSupport::TestCase

  should 'read configuration' do
    YAML.expects(:load_file).with(Rails.root.join('public/designs/templates/default/config.yml')).returns({'number_of_boxes' => 3, 'description' => 'my description', 'title' => 'my title'})
    t = LayoutTemplate.find('default')
    assert_equal 3, t.number_of_boxes
    assert_equal 'my description', t.description
    assert_equal 'my title', t.title
  end

  should 'list all' do
    Dir.expects(:glob).with(Rails.root.join('public/designs/templates/*')).returns([Rails.root.join('public/designs/templates/one'), Rails.root.join('public/designs/templates/two')])
    YAML.expects(:load_file).with(Rails.root.join('public/designs/templates/one/config.yml')).returns({})
    YAML.expects(:load_file).with(Rails.root.join('public/designs/templates/two/config.yml')).returns({})

    all = LayoutTemplate.all
    assert_equivalent [ 'one', 'two' ], all.map(&:id)
  end
  
end
