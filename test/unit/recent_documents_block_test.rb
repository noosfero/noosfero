require File.dirname(__FILE__) + '/../test_helper'

class RecentDocumentsBlockTest < Test::Unit::TestCase

  # Replace this with your real tests.
  def test_should_output_list_with_links_to_recent_documents
    profile = mock
    profile.stubs(:identifier).returns('a_test_profile')

    doc1 = mock
    doc2 = mock
    doc3 = mock
    profile.expects(:recent_documents).returns([doc1, doc2, doc3])

    helper = mock
    helper.expects(:profile).returns(profile)
    helper.expects(:link_to_document).with(doc1).returns('doc1')
    helper.expects(:link_to_document).with(doc2).returns('doc2')
    helper.expects(:link_to_document).with(doc3).returns('doc3')
    helper.expects(:content_tag).with('ul', "doc1\ndoc2\ndoc3").returns('the_tag')

    assert_equal('the_tag', helper.instance_eval(&RecentDocumentsBlock.new.content))
  end
end
