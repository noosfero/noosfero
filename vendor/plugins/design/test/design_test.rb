require File.join(File.dirname(__FILE__), 'test_helper')

class FixedDesignHolderTest < Test::Unit::TestCase

  def test_design_should_include_design_module
    assert FixedDesignTestController.included_modules.include?(Design)
  end

  def test_design_editor_should_include_design_and_design_editor_module
    assert DesignEditorTestController.included_modules.include?(Design)
    assert DesignEditorTestController.included_modules.include?(Design::Editor)
  end

  def test_should_not_accept_no_holder_and_no_fixed
    assert_raise ArgumentError do
      DesignEditorTestController.design
    end
  end
  def test_should_not_accept_both_holder_and_fixed
    assert_raise ArgumentError do
      DesignEditorTestController.design :holder => 'something', :fixed => true end
  end

end
