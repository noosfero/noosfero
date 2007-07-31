require File.join(File.dirname(__FILE__), 'test_helper')


class ProxyDesignHolderTest < Test::Unit::TestCase

  # FIXME: rewrite this test with mocha
  def test_design_should_interact_with_sample_holder
    design = Design::ProxyDesignHolder.new(SampleHolderForTestingProxyDesignHolder.new)
    design.template = 'bli'
    assert_equal 'bli', design.template
    design.theme = 'bli'
    assert_equal 'bli', design.theme
    design.icon_theme = 'bli'
    assert_equal 'bli', design.icon_theme
    design.boxes = []
    assert_equal [], design.boxes
  end

  def test_design_user_controller_should_get_a_proper_design
    controller = ProxyDesignHolderTestController.new
    design = controller.send(:design)
    design.template = 'bli'
    assert_equal 'bli', design.template
    design.theme = 'bli'
    assert_equal 'bli', design.theme
    design.icon_theme = 'bli'
    assert_equal 'bli', design.icon_theme
    design.boxes = []
    assert_equal [], design.boxes
  end

  def test_should_not_proxy_unrelated_method_calls
    assert_raise NoMethodError do
      design = Design::ProxyDesignHolder.new(1)
      design.succ
    end
  end

end
