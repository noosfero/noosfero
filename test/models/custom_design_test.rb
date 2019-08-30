require_relative "../test_helper"

class CustomDesignTest < ActionView::TestCase
  include CustomDesign
  include ActionView::Helpers::TagHelper

  def setup
  end

  should "allow class instance customization of custom design" do
    self.class.use_custom_design boxes_limit: 1
    assert_equal({ boxes_limit: 1 }, self.custom_design)
    @custom_design = { boxes_limit: 2 }
    assert_equal({ boxes_limit: 2 }, self.custom_design)
  end
end
