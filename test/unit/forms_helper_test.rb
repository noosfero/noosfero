require File.dirname(__FILE__) + '/../test_helper'

class FormsHelperTest < ActiveSupport::TestCase

  include FormsHelper
  include ActionView::Helpers::TagHelper

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

  protected

  def _(text)
    text
  end

end
