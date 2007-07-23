require File.dirname(__FILE__) + '/../test_helper'
require 'test_controller'

# Re-raise errors caught by the controller.
class TestController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < Test::Unit::TestCase

  fixtures :profiles, :virtual_communities, :domains, :boxes

  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_against_post_only
    get :post_only
    assert_redirected_to :action => 'index'
  end
  def test_post_against_post_only
    post :post_only
    assert_response :success
    assert_tag :tag => 'span', :content => 'post_only'
  end


  def test_load_template_default
    get :index
    assert_equal assigns(:chosen_template), 'default'
  end

  def test_load_template_other
    p = Profile.find(1)
    p.template = "other"
    p.save
    get :index
    assert_equal assigns(:chosen_template), 'other'
  end

  def test_exist_owner
    get :index
    assert_not_nil assigns(:owner)
  end

  def test_exist_chosen_theme
    get :index
    assert_not_nil assigns(:chosen_theme)
  end

  def test_exist_chosen_icons_theme
    get :index
    assert_not_nil assigns(:chosen_icons_theme)
  end

  def test_should_generate_help_box_when_passing_string
    get :help_with_string
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :content => /my_help_message/,
        :attributes => { :class => 'help_message'}
      }
    })
  end

  def test_should_generate_help_box_when_passing_block
    get :help_with_block
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :content => /my_help_message/,
        :attributes => { :class => 'help_message'}
      }
    })
  end

  def test_should_generate_help_box_expanding_textile_markup_when_passing_string
    get :help_textile_with_string
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message'},
        :descendant => {
          :tag => 'strong',
          :content => /my_bold_help_message/
        }
      }
    })
  end

  def test_should_generate_help_box_expanding_textile_markup_when_passing_block
    get :help_textile_with_block
    assert_tag({
      :tag => 'div',
      :attributes => { :class => 'help_box'},
      :descendant => {
        :tag => 'div',
        :attributes => { :class => 'help_message'},
        :descendant => {
          :tag => 'strong',
          :content => /my_bold_help_message/
        }
      }
    })
  end

end
