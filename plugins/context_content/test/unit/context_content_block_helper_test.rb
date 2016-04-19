require 'test_helper'

class ContextContentBlockHelperTest < ActionView::TestCase
  include ContextContentBlockHelper

  should 'display thumbnail for image content' do
    content = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    content = FilePresenter.for(content)
    expects(:image_tag).once
    content_image(content)
  end

  should 'display div as content image for content that is not a image' do
    content = fast_create(Folder)
    content = FilePresenter.for(content)
    expects(:content_tag).once
    content_image(content)
  end

  should 'display div with extension class for uploaded file that is not an image' do
    content = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    content = FilePresenter.for(content)
    expects(:content_tag).with('div', '', :class => "context-icon icon-text icon-text-plain extension-txt").once
    content_image(content)
  end

end
