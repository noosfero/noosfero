require File.dirname(__FILE__) + '/../test_helper'

class FolderHelperTest < Test::Unit::TestCase

  include FolderHelper

  should 'display icon for articles' do
    art1 = mock; art1.expects(:icon_name).returns('icon1')
    art2 = mock; art2.expects(:icon_name).returns('icon2')

    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'images', 'icons-mime', 'icon1.png')).returns(true)
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'images', 'icons-mime', 'icon2.png')).returns(false)

    assert_equal 'icons-mime/icon1.png', icon_for_article(art1)
    assert_equal 'icons-mime/unknown.png', icon_for_article(art2)
  end

end
