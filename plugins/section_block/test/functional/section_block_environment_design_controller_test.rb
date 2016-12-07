require 'test_helper'

class EnvironmentDesignControllerTest < ActionController::TestCase

  def setup
    Environment.delete_all
    @environment = Environment.new(:name => 'testenv', :is_default => true)
    @environment.enabled_plugins = ['SectionBlockPlugin::SectionBlock']
    @environment.save!

    user = create_user('testinguser')
    @environment.add_admin(user.person)
    login_as(user.login)

    @block = create(SectionBlockPlugin::SectionBlock, :box => @environment.boxes.first)
  end

  should 'be able to edit SectionBlock' do
    get :edit, :id => @block.id
    assert_tag :tag => 'input', :attributes => { :id => 'block_title' }
  end

  should 'be able to save SectionBlock' do
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:title => 'Section' }
    @block.reload
    assert_equal 'Section', @block.title
  end

  should 'display section block' do
    get :index
    assert_tag :div, :attributes => { :id => "section-block-#{@block.id}" }
  end

  should 'display section name' do
    get :index
    assert_tag :span, :attributes => { :class => "section-block-name" }
  end

  should 'display section description' do
    get :index
    assert_tag :span, :attributes => { :class => "section-block-description" }
  end

end
