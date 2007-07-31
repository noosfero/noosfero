require File.join(File.dirname(__FILE__), 'test_helper')

class DesignHelperTestController < ActionController::Base
  
  box1 = Design::Box.new(:number => 1)

  proc_block = Design::Block.new(:position => 1)
  def proc_block.content
    lambda do
      link_to 'test link', :controller => 'controller_linked_from_block'
    end
  end
  box1.blocks << proc_block

  array_block = Design::Block.new(:position => 2)
  def array_block.content
    [ 'item1', 'item2', 'item3' ]
  end
  box1.blocks << array_block

  box2 = Design::Box.new(:number => 2)
  box2.blocks << Design::MainBlock.new(:position => 1)

  box3 = Design::Box.new(:number => 3)
  fixed_text_block = Design::Block.new(:position => 1)
  def fixed_text_block.content
    "this is a fixed content block hacked for testing"
  end
  box3.blocks << fixed_text_block

  design :fixed => {
    :template => 'default',
    :theme => 'default',
    :icon_theme => 'default',
    :boxes => [ box1, box2, box3 ],
  }

  def index
    render :inline => '<%= design_display("my content") %>'
  end
end

class DesignHelperTest < Test::Unit::TestCase

  def setup
    @controller = DesignHelperTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_generate_all_boxes
    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'box_1' }
    assert_tag :tag => 'div', :attributes => { :id => 'box_2' }
    assert_tag :tag => 'div', :attributes => { :id => 'box_3' }
  end

  def test_should_render_array_as_list
    get :index
    assert_tag :tag => 'ul', :descendant => {
      :tag => 'li', :content => 'item1'
    }
    assert_tag :tag => 'ul', :descendant => {
      :tag => 'li', :content => 'item2'
    }
    assert_tag :tag => 'ul', :descendant => {
      :tag => 'li', :content => 'item3'
    }
  end

  def test_should_process_block_returned_as_content
    get :index
    assert_tag :tag => 'a', :attributes => { :href => /controller_linked_from_block/ }
  end

  def test_should_put_string_as_is
    get :index
    assert_tag :tag => 'div', :content => "this is a fixed content block hacked for testing", :attributes => { :class => 'block' }
  end

end
