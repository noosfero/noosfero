require_relative '../test_helper'

class ProfileDesignControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @environment.enabled_plugins = ['StatisticsPlugin']
    @environment.save!

    user = create_user('testinguser')
    @person = user.person
    @environment.add_admin(@person)

    StatisticsBlock.delete_all
    @box1 = Box.create!(:owner => @person)

    @block = StatisticsBlock.new
    @block.box = @box1
    @block.save!

    login_as(user.login)
  end

  attr_accessor :block

  should 'be able to edit StatisticsBlock' do
    get :edit, :id => @block.id, :profile => @person.identifier
    assert_tag :tag => 'input', :attributes => { :id => 'block_title' }
  end

  should 'be able to save StatisticsBlock' do
    get :edit, :id => @block.id, :profile => @person.identifier
    post :save, :id => @block.id, :block => {:title => 'Statistics' }, :profile => @person.identifier
    @block.reload
    assert_equal 'Statistics', @block.title
  end

  should 'be able to uncheck core counters' do
    @block.user_counter = true
    @block.tag_counter = true
    @block.comment_counter = true
    @block.hit_counter = true
    @block.save!
    get :edit, :id => @block.id, :profile => @person.identifier
    post :save, :id => @block.id, :block => {:user_counter => '0', :tag_counter => '0', :comment_counter => '0', :hit_counter => '0' }, :profile => @person.identifier
    @block.reload
    any_checked = @block.is_visible?('user_counter') ||
                  @block.is_visible?('tag_counter') ||
                  @block.is_visible?('comment_counter') ||
                  @block.is_visible?('hit_counter')
    assert_equal false, any_checked
  end

  should 'be able to check core counters' do
    @block.user_counter = false
    @block.community_counter = false
    @block.enterprise_counter = false
    @block.category_counter = false
    @block.tag_counter = false
    @block.comment_counter = false
    @block.hit_counter = false
    @block.save!
    get :edit, :id => @block.id, :profile => @person.identifier
    post :save, :id => @block.id, :block => {:user_counter => '1',
      :tag_counter => '1', :comment_counter => '1', :hit_counter => '1' }, :profile => @person.identifier
    @block.reload
    all_checked = @block.is_visible?('user_counter') &&
                  @block.is_visible?('tag_counter') &&
                  @block.is_visible?('comment_counter') &&
                  @block.is_visible?('hit_counter')
    assert all_checked

  end

end
