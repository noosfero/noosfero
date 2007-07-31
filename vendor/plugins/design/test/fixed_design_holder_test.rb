require File.join(File.dirname(__FILE__), 'test_helper')

class FixedDesignHolderTest < Test::Unit::TestCase

  include Design

  def test_explicit_design
    controller = FixedDesignTestController.new
    assert_kind_of Design::FixedDesignHolder, controller.design
    assert_equal 'some_template', controller.design.template
    assert_equal 'some_theme', controller.design.theme
    assert_equal 'some_icon_theme', controller.design.icon_theme
    assert_equal [FixedDesignTestController::BOX1, FixedDesignTestController::BOX2, FixedDesignTestController::BOX3], controller.design.boxes
  end

  def test_explicit_design_should_have_sensible_defaults
    controller = FixedDesignDefaultTestController.new
    assert_kind_of Design::FixedDesignHolder, controller.design
    assert_equal 'default', controller.design.template
    assert_equal 'default', controller.design.theme
    assert_equal 'default', controller.design.icon_theme
    assert_kind_of Array, controller.design.boxes
    assert_equal 3, controller.design.boxes.size
  end

  def test_should_not_be_able_to_assign_template
    # FixedDesignHolder does not implement assigment, on purpose
    assert_raise NoMethodError do
      FixedDesignHolder.new.template = 'break'
    end
  end

  def test_should_not_be_able_to_assign_theme
    # FixedDesignHolder does not implement assigment, on purpose
    assert_raise NoMethodError do
      FixedDesignHolder.new.theme = 'break'
    end
  end

  def test_should_not_be_able_to_assign_icon_theme
    assert_raise NoMethodError do
      FixedDesignHolder.new.icon_theme = 'break'
    end
  end

  def test_should_not_be_able_to_assign_boxes
    assert_raise NoMethodError do
      FixedDesignHolder.new.boxes = []
    end
  end


end
