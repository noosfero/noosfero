require_relative '../test_helper'

class EnvironmentDesignControllerTest < ActionController::TestCase

  def setup
    Environment.delete_all
    @environment = Environment.new(:name => 'testenv', :is_default => true)
    @environment.enabled_plugins = ['CommunityTrackPlugin']
    @environment.save!

    user = create_user('testinguser')
    @environment.add_admin(user.person)
    login_as(user.login)

    box = create(Box, :owner => @environment)
    @block = create(CommunityTrackPlugin::TrackListBlock, :box => box)
    @block_card = create(CommunityTrackPlugin::TrackCardListBlock, :box => box)
  end

  should 'be able to edit TrackListBlock' do
    get :edit, :id => @block.id
    assert_tag :tag => 'input', :attributes => { :id => 'block_title' }
  end

  should 'be able to save TrackListBlock' do
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:title => 'Tracks' }
    @block.reload
    assert_equal 'Tracks', @block.title
  end

  should 'be able to edit TrackCardListBlock' do
    get :edit, :id => @block_card.id
    assert_tag :tag => 'input', :attributes => { :id => 'block_title' }
  end

  should 'be able to save TrackCardListBlock' do
    get :edit, :id => @block_card.id
    post :save, :id => @block_card.id, :block => {:title => 'Tracks' }
    @block_card.reload
    assert_equal 'Tracks', @block_card.title
  end

end
