require_relative "../test_helper"

class FilePresenterTest < ActiveSupport::TestCase

  should 'notify about deprecated method UploadedFile.icon_name' do
    profile = fast_create(Profile)
    file = UploadedFile.create!(
             :profile => profile,
             :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
           )
    assert_raise NoMethodError do
      UploadedFile.icon_name file
    end
    ENV.stubs('[]').with('RAILS_ENV').returns('other')
    Rails.logger.expects(:warn) # must warn on any other RAILS_ENV
    stubs(:puts)
    UploadedFile.icon_name file
  end

  should 'notify about deprecated method UploadedFile#to_html' do
    profile = fast_create(Profile)
    file = UploadedFile.create!(
             :profile => profile,
             :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
           )
    assert_raise NoMethodError do
      file.to_html
    end
    ENV.stubs('[]').with('RAILS_ENV').returns('other')
    Rails.logger.expects(:warn) # must warn on any other RAILS_ENV
    stubs(:puts)
    file.to_html
  end

  should 'return a thumbnail as icon for images ' do
    f = UploadedFile.new
    f.stubs(:image?).returns(true)
    p = FilePresenter.for f
    p.expects(:public_filename).with(:icon).returns('/path/to/file.xyz')
    assert_equal '/path/to/file.xyz', p.icon_name
  end

  should 'not crach when accepts? method receives a pure article' do
    assert_nothing_raised do
      FilePresenter.for Article.new
    end
  end

  should 'not crach when accepts? method receives a non-sense object' do
    assert_nothing_raised do
      FilePresenter.for nil
    end
    assert_nothing_raised do
      FilePresenter.for({:key => 'value'})
    end
    assert_nothing_raised do
      FilePresenter.for 'a string'
    end
  end

  should 'pass kind_of? to the encapsulated file' do
    f = FilePresenter.for(UploadedFile.new)
    assert f.kind_of?(UploadedFile)
  end

  should 'not crash with uploaded_file short description without content_type' do
    f = FilePresenter.for(UploadedFile.new)
    assert_nothing_raised do
      f.short_description
    end
  end

  should 'show unknown type when file doesn\'t have a content_type' do
    f = FilePresenter.for(UploadedFile.new)
    assert_match /Unknown/, f.short_description
  end
end
