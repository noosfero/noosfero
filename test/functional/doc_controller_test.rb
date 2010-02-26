require File.dirname(__FILE__) + '/../test_helper'

class DocControllerTest < ActionController::TestCase

  should 'load toc in the root' do
    get :index
    assert_kind_of DocItem, assigns(:toc)
  end

  should 'display root document in the index' do
    get :index
    root = assigns(:index)
    assert_kind_of DocSection, root
  end

  should 'translate the index' do
    get :index
    assert_equal 'en', assigns(:index).language

    @controller.stubs(:language).returns('pt')
    get :index
    assert_equal 'pt', assigns(:index).language
  end

  should 'translate section' do
    get :section, :section => 'user'
    assert_equal 'en', assigns(:section).language

    @controller.stubs(:language).returns('pt')
    get :section, :section => 'user'
    assert_equal 'pt', assigns(:section).language
  end

  should 'translate topic' do
    get :topic, :section => 'user', :topic => 'accepting-friends'
    assert_equal 'en', assigns(:topic).language

    @controller.stubs(:language).returns('pt')
    get :topic, :section => 'user', :topic => 'accepting-friends'
    assert_equal 'pt', assigns(:topic).language
  end

  should 'use environment theme' do
    e = Environment.default
    e.theme = 'test-theme'
    e.save

    DocTopic.any_instance.expects(:html).with('test-theme')
    get :topic, :section => 'user', :topic => 'accepting-friends'
  end

  should 'bail out gracefully for unexisting sections or topics' do
    assert_nothing_raised do
      get :section, :section => 'something-very-unlikely'
      get :section, :section => 'something-very-unlikely', :topic => 'other-thing-very-unlikely'
    end
  end

end
