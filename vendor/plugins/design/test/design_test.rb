require File.join(File.dirname(__FILE__), 'test_helper')

class DesignTest < Test::Unit::TestCase

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

  def test_should_not_accept_non_hash
    assert_raise ArgumentError do
      DesignEditorTestController.design :fixed
    end
  end

  def test_should_expose_config_passed_to_design_class_method
    assert_kind_of Hash, FixedDesignTestController.design_plugin_config
  end

  def test_should_be_able_to_change_design_root
    Design.design_root = 'some_design_root'
    assert_equal 'some_design_root', Design.design_root
    Design.design_root = nil # reset
  end

  def test_should_provide_a_sensible_default_for_design_root
    Design.design_root = nil
    assert_equal File.join('designs'), Design.design_root
  end

  # used for testing
  def test_changing_public_filesystem_root
    Design.public_filesystem_root = 'test'
    assert_equal 'test', Design.public_filesystem_root
    Design.public_filesystem_root = nil
    assert_equal File.join(RAILS_ROOT, 'public'), Design.public_filesystem_root
  end

  def test_subclass_controller_can_override_superclass_design_holder
    assert_equal 'sample_object', ProxyDesignHolderTestController.send(:design_plugin_config)[:holder]
    assert_equal 'another_object', InheritanceDesignTestController.send(:design_plugin_config)[:holder]

  end

end
