require_relative "../test_helper"

class FormsHelperTest < ActiveSupport::TestCase

  include FormsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormOptionsHelper

  should 'wrapper required fields in <span class=required-field>' do
    content = required('<input type=text name=test>')
    assert_tag_in_string content, :tag => 'span', :attributes => {:class => 'required-field'}
  end

  should 'wrapper required fields message in <span class=required-field>' do
    content = required_fields_message()
    assert_tag_in_string content, :tag => 'span', :attributes => {:class => 'required-field'}
  end

  should 'wrapper highlighted in label pseudoformlabel' do
    content = required_fields_message()
    assert_tag_in_string content, :tag => 'label', :content => 'highlighted', :attributes => {:class => 'pseudoformlabel'}
  end

  should 'show title for option in select' do
    content = options_for_select_with_title({'option_value' => 'option_title'})
    assert_tag_in_string content, :tag => 'option', :attributes => {:title => 'option_value'}
  end

  protected
  include NoosferoTestHelper

end
