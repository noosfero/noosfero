require File.dirname(__FILE__) + '/../test_helper'

class FormsHelperTest < Test::Unit::TestCase

  include FormsHelper
  include ActionView::Helpers::TagHelper

  should 'wrapper required fields in <span class=required-field>' do
    content = required('<input type=text name=test>')
    assert_tag_in_string content, :tag => 'span', :attributes => {:class => 'required-field'}
  end

end
