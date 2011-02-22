require File.dirname(__FILE__) + '/../test_helper'

class GalleryTest < ActionController::IntegrationTest

  def setup
    p = create_user('test_user').person
    g = fast_create(Gallery, :profile_id => p.id, :path => 'pics')
    image = UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'),
      :parent => g,
      :profile => p,
      :title => 'my img1 title',
      :abstract => 'my img1 <b>long description</b>'
    )
    image = UploadedFile.create!(
      :uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'),
      :parent => g,
      :profile => p,
      :title => '<b must scape title>',
      :abstract => 'that is my picture description'
    )
    get '/test_user/pics'
  end

  should 'display the title of the images when listing' do
    assert_tag :tag => 'li',  :attributes => { :title => 'my img1 title' }
    assert_select '.image-gallery-item span', 'my img1 title'
    assert_no_match(/my img1 <b>long description/, @response.body)
  end

  should 'scape the title of the images' do
    assert_select '.image-gallery-item:first-child span',
                  '&lt;b must scape title&gt;'
  end

end
