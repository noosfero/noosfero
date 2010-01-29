require 'test_helper'

class DocTopicTest < ActiveSupport::TestCase
  should 'be a DocItem' do
    assert_kind_of DocItem, DocTopic.new
  end

  should 'load topic data from file' do
    doc = DocTopic.loadfile(RAILS_ROOT + '/' + 'test/fixtures/files/doctest.en.xhtml')
    assert_equal 'en', doc.language
    assert_equal 'Documentation test', doc.title
    assert_match(/Documentation test/, doc.text)
    assert_match(/This is a test document/, doc.text)
  end

  should 'load translated topic from file' do
    doc = DocTopic.loadfile(RAILS_ROOT + '/' + 'test/fixtures/files/doctest.pt.xhtml')
    assert_equal 'pt', doc.language
    assert_equal 'Teste da documentação', doc.title
  end
end
