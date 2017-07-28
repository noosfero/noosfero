require_relative "../test_helper"

class SanitizeHelperTest < ActionView::TestCase

  should 'permit white_list attributes on links' do
    allowed_attributes.each do |attribute|
      assert_match /#{attribute}/, sanitize_link("<a #{attribute.to_sym}='value' />")
    end
  end

  should 'replace string content if it contains string params' do
    obj = mock
    obj.stubs(:id).returns('1')
    obj.stubs(:title).returns('ze')

    str = parse_string_params(obj, '!id should be replaced for !title')
    assert_equal '1 should be replaced for ze', str
  end

  should 'not replace string content if string params do not exist' do
    obj = mock
    str = '!!!this !invalid is not a param!!!'
    assert_equal str, parse_string_params(obj, str)
  end

  should 'use string params for a Block' do
    obj = mock
    obj.stubs(:class).returns(Block)
    obj.stubs(:owner).returns(obj)
    obj.stubs(:name).returns('it works')

    assert_equal 'it works', parse_string_params(obj, '!name')
  end

  should 'use string params for an Article' do
    obj = mock
    obj.stubs(:class).returns(Article)
    obj.stubs(:author).returns(obj)
    obj.stubs(:name).returns('it works')

    assert_equal 'it works', parse_string_params(obj, '!name')
  end

  should 'use default params if it the object class is not supported' do
    obj = mock
    obj.stubs(:class).returns(Environment)
    obj.stubs(:id).returns('1')

    assert_equal '!name 1', parse_string_params(obj, '!name !id')
  end
end
