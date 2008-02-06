require File.join(File.dirname(__FILE__), 'test_helper')
require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'doc_browser')

class DocBroserTest < Test::Unit::TestCase

  def roots(name)
    File.join(File.dirname(__FILE__), 'fixtures', name)
  end

  def test_should_list_existing_docs
    docs = DocBrowser.find_docs(roots('regular'))
    assert_kind_of Array, docs
    assert_equal 3, docs.size
  end

  def test_should_detect_missing_symlink
    errors = DocBrowser.errors(roots('no_symlink'))
    assert(errors.any? do |item|
      item =~ /no symbolic link/
    end)
  end

end
