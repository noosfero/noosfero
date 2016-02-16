require_relative '../test_helper'

class EnvironmentDesignControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @environment.enabled_plugins = ['StatisticsPlugin']
    @environment.save!

    user = create_user('testinguser')
    @environment.add_admin(user.person)

    StatisticsBlock.delete_all
    @box1 = Box.create!(:owner => @environment)
    @environment.boxes = [@box1]

    @block = StatisticsBlock.new
    @block.box = @box1
    @block.save!

    login_as(user.login)
  end

  attr_accessor :block

  should 'be able to edit StatisticsBlock' do
    get :edit, :id => @block.id
    assert_tag :tag => 'input', :attributes => { :id => 'block_title' }
  end

  should 'be able to save StatisticsBlock' do
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:title => 'Statistics' }
    @block.reload
    assert_equal 'Statistics', @block.title
  end

  should 'be able to uncheck core counters' do
    @block.user_counter = true
    @block.community_counter = true
    @block.enterprise_counter = true
    @block.product_counter = true
    @block.category_counter = true
    @block.tag_counter = true
    @block.comment_counter = true
    @block.hit_counter = true
    @block.save!
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:user_counter => '0', :community_counter => '0', :enterprise_counter => '0', :product_counter => '0', :category_counter => '0', :tag_counter => '0', :comment_counter => '0', :hit_counter => '0'}
    @block.reload
    any_checked = @block.is_visible?('user_counter') ||
                  @block.is_visible?('community_counter') ||
                  @block.is_visible?('enterprise_counter') ||
                  @block.is_visible?('product_counter') ||
                  @block.is_visible?('category_counter') ||
                  @block.is_visible?('tag_counter') ||
                  @block.is_visible?('comment_counter') ||
                  @block.is_visible?('hit_counter')
    assert_equal false, any_checked

  end

  should 'be able to check core counters' do
    @block.user_counter = false
    @block.community_counter = false
    @block.enterprise_counter = false
    @block.product_counter = false
    @block.category_counter = false
    @block.tag_counter = false
    @block.comment_counter = false
    @block.hit_counter = false
    @block.save!
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:user_counter => '1', :community_counter => '1', :enterprise_counter => '1', :product_counter => '1',
      :category_counter => '1', :tag_counter => '1', :comment_counter => '1', :hit_counter => '1' }
    @block.reload
    all_checked = @block.is_visible?('user_counter') &&
                  @block.is_visible?('community_counter') &&
                  @block.is_visible?('enterprise_counter') &&
                  @block.is_visible?('product_counter') &&
                  @block.is_visible?('category_counter') &&
                  @block.is_visible?('tag_counter') &&
                  @block.is_visible?('comment_counter') &&
                  @block.is_visible?('hit_counter')
    assert all_checked

  end

  should 'be able to check template counters' do
    template = fast_create(Community, :name => 'Councils', :is_template => true, :environment_id => @environment.id)
    @block.templates_ids_counter = {template.id.to_s => 'false'}
    @block.save!
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:templates_ids_counter => {template.id.to_s => 'true'}}
    @block.reload

    assert @block.is_template_counter_active?(template.id)
  end

  should 'be able to uncheck template counters' do
    template = fast_create(Community, :name => 'Councils', :is_template => true, :environment_id => @environment.id)
    @block.templates_ids_counter = {template.id.to_s => 'true'}
    @block.save!
    get :edit, :id => @block.id
    post :save, :id => @block.id, :block => {:templates_ids_counter => {template.id.to_s => 'false'}}
    @block.reload

    assert_equal false, @block.is_template_counter_active?(template.id)
  end

  should 'input user counter be checked by default' do
    get :edit, :id => @block.id

    assert_tag :input, :attributes => {:id => 'block_user_counter', :checked => 'checked'}
  end

  should 'not input community counter be checked by default' do
    get :edit, :id => @block.id

    assert_tag :input, :attributes => {:id => 'block_community_counter'}
    assert_no_tag :input, :attributes => {:id => 'block_community_counter', :checked => 'checked'}
  end

  should 'not input enterprise counter be checked by default' do
    get :edit, :id => @block.id

    assert_tag :input, :attributes => {:id => 'block_enterprise_counter'}
    assert_no_tag :input, :attributes => {:id => 'block_enterprise_counter', :checked => 'checked'}
  end

  should 'not input product counter be checked by default' do
    get :edit, :id => @block.id

    assert_tag :input, :attributes => {:id => 'block_product_counter'}
    assert_no_tag :input, :attributes => {:id => 'block_product_counter', :checked => 'checked'}
  end

  should 'not input category counter be checked by default' do
    get :edit, :id => @block.id

    assert_tag :input, :attributes => {:id => 'block_category_counter'}
    assert_no_tag :input, :attributes => {:id => 'block_category_counter', :checked => 'checked'}
  end

  should 'input tag counter be checked by default' do
    get :edit, :id => @block.id

    assert_tag :input, :attributes => {:id => 'block_tag_counter', :checked => 'checked'}
  end

  should 'input comment counter be checked by default' do
    get :edit, :id => @block.id

    assert_tag :input, :attributes => {:id => 'block_comment_counter', :checked => 'checked'}
  end

  should 'input hit counter not be checked by default' do
    get :edit, :id => @block.id

    assert_no_tag :input, :attributes => {:id => 'block_hit_counter', :checked => 'checked'}
  end
end
