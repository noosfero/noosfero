require_relative "../test_helper"

class SanitizeHelperTest < ActionView::TestCase

  should 'permit white_list attributes on links' do
    allowed_attributes.each do |attribute|
      assert_match /#{attribute}/, sanitize_link("<a #{attribute.to_sym}='value' />")
    end
  end

  should 'replace string content if it contains string params' do
    article = fast_create(Article)
    str = parse_string_params(article, '!id should be replaced for !article_name')
    assert_equal "#{article.id} should be replaced for #{article.title}", str
  end

  should 'not replace string content if string params do not exist' do
    article = fast_create(Article)
    str = '!!!this !invalid is not a param!!!'
    assert_equal str, parse_string_params(article, str)
  end

  should 'use string params for a Block' do
    block = fast_create(Block)

    assert_equal block.title, parse_string_params(block, '!title')
  end

  should 'use default params if it the object class is not supported' do
    obj = mock
    obj.stubs(:class).returns(Environment)
    obj.stubs(:id).returns('1')

    assert_equal '!name 1', parse_string_params(obj, '!name !id')
  end
end
