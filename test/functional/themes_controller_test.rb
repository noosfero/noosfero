require File.dirname(__FILE__) + '/../test_helper'

class ThemesControllerTest < ActionController::TestCase

  should 'display list of themes for selection' do
    profile = create_user('testinguser').person
    Theme.expects(:system_themes).returns([Theme.new('first'), Theme.new('second')])
    get :index, :profile => 'testinguser'

    %w[ first second ].each do |item|
      assert_tag :tag => 'a', :attributes => { :href => "/myprofile/testinguser/themes/set/#{item}" }, :descendant => { :tag => 'img' }
    end
  end

  should 'save selection of theme' do
    profile = create_user('testinguser').person

    get :set, :profile => 'testinguser', :id => 'onetheme'
    profile.reload
    assert_equal 'onetheme', profile.theme
  end

  should 'point back to control panel' do
    create_user('testinguser').person
    get :index, :profile => 'testinguser'
    assert_tag :tag => 'a', :attributes => { :href =>  '/myprofile/testinguser' }, :content => 'Back'
  end

  should 'check access control when choosing theme'

  should 'check access control when editing themes'

  should 'only allow environment-approved themes to be selected'

  should 'list user-created themes with link for editing'

  should 'offer to create new theme'

  should 'be able to save new theme'

  should 'be able to save existing theme'

end
