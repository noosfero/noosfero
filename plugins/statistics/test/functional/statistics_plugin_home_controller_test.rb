require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < ActionController::TestCase

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

  should 'display statistics-block-data class in environment block edition' do
    get :index

    assert_tag :div, :attributes => {:class => 'statistics-block-data'}
  end

  should 'display users class in statistics-block-data block' do
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'users'} }
  end

  should 'not display users class in statistics-block-data block' do
    @block.user_counter = false
    @block.save!
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'users'} }
  end

  should 'display communities class in statistics-block-data block' do
    @block.community_counter = true
    @block.save!
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'communities'} }
  end

  should 'not display communities class in statistics-block-data block' do
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'communities'} }
  end

  should 'display enterprises class in statistics-block-data block' do
    @block.enterprise_counter = true
    @block.save!
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'enterprises'} }
  end

  should 'not display enterprises class in statistics-block-data block' do
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'enterprises'} }
  end

  should 'display products class in statistics-block-data block' do
    @block.product_counter = true
    @environment.enable('products_for_enterprises')
    @block.save!
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'products'} }
  end

  should 'not display products class in statistics-block-data block' do
    @block.product_counter = true
    @environment.disable('products_for_enterprises')
    @block.save!
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'products'} }
  end

  should 'display categories class in statistics-block-data block' do
    @block.category_counter = true
    @block.save!
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'categories'} }
  end

  should 'not display categories class in statistics-block-data block' do
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'categories'} }
  end

  should 'display tags class in statistics-block-data block' do
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'tags'} }
  end

  should 'not display tags class in statistics-block-data block' do
    @block.tag_counter = false
    @block.save!
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'tags'} }
  end

  should 'display comments class in statistics-block-data block' do
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'comments'} }
  end

  should 'not display comments class in statistics-block-data block' do
    @block.comment_counter = false
    @block.save!
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'comments'} }
  end

  should 'display hits class in statistics-block-data block' do
    @block.hit_counter = true
    @block.save!
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'hits'} }
  end

  should 'not display hits class in statistics-block-data block' do
    get :index

    assert_no_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'hits'} }
  end

  should 'display template name in class in statistics-block-data block' do
    template = fast_create(Community, :name => 'Councils', :is_template => true, :environment_id => @environment.id)
    @block.templates_ids_counter = {template.id.to_s => 'true'}
    @block.save!
    get :index

    assert_tag :tag => 'div', :attributes => {:class => 'statistics-block-data'}, :descendant => { :tag => 'li', :attributes => {:class => 'councils'} }
  end
end
