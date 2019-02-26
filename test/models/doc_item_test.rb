require_relative "../test_helper"

class DocItemTest < ActiveSupport::TestCase

  should 'have id, title and text attributes' do
    item = DocItem.new
    item.id = 'my-title'; assert_equal 'my-title', item.id
    item.title = 'My title'; assert_equal 'My title', item.title
    item.text = 'My text'; assert_equal 'My text', item.text
  end

  should 'build object with attributes in hash' do
    item = DocItem.new(:title => 'The Shiny Documentation', :text => 'lorem ipsum', :language => 'tlh')
    assert_equal 'The Shiny Documentation', item.title
    assert_equal 'lorem ipsum', item.text
    assert_equal 'tlh', item.language
  end

  should 'use English as default language' do
    assert_equal 'en', DocItem.new.language
  end

  should 'expose processed text as HTML' do
    doc = DocItem.new(:text => 'this is the text')
    assert_equal 'this is the text', doc.html
  end

  should 'translate images' do
    doc = DocItem.new(:language => 'pt', :text => '<p>Look the image:</p><p><img src="/images/doc/myimage.en.png" alt="The image"/></p>')
    File.stubs(:exist?).with(Rails.root.join('public', 'images', 'doc', 'myimage.pt.png')).returns(false)
    assert_equal doc.text, doc.html

    File.stubs(:exist?).with(Rails.root.join('public', 'images', 'doc', 'myimage.pt.png')).returns(true)
    assert_match(/<img src="\/images\/doc\/myimage.pt.png"/, doc.html)
  end

  should 'replace images with the ones provided by the theme' do
    doc = DocItem.new(:language => 'pt', :text => '<p>Look the image:</p><p><img src="/images/doc/myimage.en.png" alt="The image"/></p>')

    # the image exists in both the system *and* on the theme
    File.stubs(:exist?).with(Rails.root.join('public', 'images', 'doc', 'myimage.pt.png')).returns(true)
    File.stubs(:exist?).with(Rails.root.join('public', 'designs', 'themes', 'mytheme', 'images', 'doc', 'myimage.pt.png')).returns(true)
    # the one in the theme must be used
    assert_match(/<img src="\/designs\/themes\/mytheme\/images\/doc\/myimage.pt.png"/, doc.html('mytheme'))
  end

  should 'prefer system-provided translated image to theme-provided english one' do
    doc = DocItem.new(:language => 'pt', :text => '<p>Look the image:</p><p><img src="/images/doc/myimage.en.png" alt="The image"/></p>')

    # the image has a translation in the system but not in the theme
    File.stubs(:exist?).with(Rails.root.join('public', 'images', 'doc', 'myimage.pt.png')).returns(true)
    File.stubs(:exist?).with(Rails.root.join('public', 'designs', 'themes', 'mytheme', 'images', 'doc', 'myimage.en.png')).returns(false)
    File.stubs(:exist?).with(Rails.root.join('public', 'designs', 'themes', 'mytheme', 'images', 'doc', 'myimage.pt.png')).returns(false)
    # the one in the theme must be used
    assert_match(/<img src="\/images\/doc\/myimage.pt.png"/, doc.html('mytheme'))
  end

  should 'prefer theme-provided untranslated image if system does not have a translation' do
    doc = DocItem.new(:language => 'pt', :text => '<p>Look the image:</p><p><img src="/images/doc/myimage.en.png" alt="The image"/></p>')

    # the image has no translation, but both system and theme provide an image
    File.stubs(:exist?).with(Rails.root.join('public', 'images', 'doc', 'myimage.en.png')).returns(true)
    File.stubs(:exist?).with(Rails.root.join('public', 'images', 'doc', 'myimage.pt.png')).returns(false)
    File.stubs(:exist?).with(Rails.root.join('public', 'designs', 'themes', 'mytheme', 'images', 'doc', 'myimage.en.png')).returns(true)
    File.stubs(:exist?).with(Rails.root.join('public', 'designs', 'themes', 'mytheme', 'images', 'doc', 'myimage.pt.png')).returns(false)
    # the one in the theme must be used
    assert_match(/<img src="\/designs\/themes\/mytheme\/images\/doc\/myimage.en.png"/, doc.html('mytheme'))
  end

end
