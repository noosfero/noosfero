require File.join(File.dirname(__FILE__), 'test_helper')

class DesignHelperTestController < ActionController::Base
  
  box1 = Design::Box.new(:number => 1)
  box2 = Design::Box.new(:number => 2)
  box2.blocks << Design::MainBlock.new
  box3 = Design::Box.new(:number => 3)

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

  def test_should_generate_template
    get :index
    assert_tag :tag => 'div', :attributes => { :id => 'box_1' }
    assert_tag :tag => 'div', :attributes => { :id => 'box_2' }
    assert_tag :tag => 'div', :attributes => { :id => 'box_3' }
  end

end
