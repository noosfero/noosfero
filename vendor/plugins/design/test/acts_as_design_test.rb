require File.join(File.dirname(__FILE__), 'test_helper')

class ActsAsDesignTest < Test::Unit::TestCase

  def setup
    Design.public_filesystem_root = File.join(File.dirname(__FILE__))
  end

  def teardown
    Design.public_filesystem_root = nil
  end

  def test_should_provide_template_attribute
    user = DesignTestUser.new
    assert_equal 'default', user.template
    user.template = 'other'
    assert_equal 'other', user.template
    user.template = nil
    assert_equal 'default', user.template
  end
  
  def test_should_provide_theme_attribute
    user = DesignTestUser.new
    assert_equal 'default', user.theme
    user.theme = 'other'
    assert_equal 'other', user.theme
    user.theme = nil
    assert_equal 'default', user.theme
  end

  def test_should_provide_icon_theme_attribute
    user = DesignTestUser.new
    assert_equal 'default', user.icon_theme
    user.icon_theme = 'other'
    assert_equal 'other', user.icon_theme
    user.icon_theme = nil
    assert_equal 'default', user.icon_theme
  end

  def test_should_store_data_in_a_hash
    user = DesignTestUser.new
    assert_kind_of Hash, user.design_data
  end

  def test_should_provide_association_with_boxes
    user = DesignTestUser.new
    assert user.boxes << Design::Box.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      user.boxes << 1
    end
  end

  def test_should_create_boxes_when_creating

    DesignTestUser.delete_all
    Design::Box.delete_all

    user = DesignTestUser.create!(:name => 'A test user')

    # default template (test/designs/templates/default/default.yml) defines
    # 3 boxes
    assert_equal 3, Design::Template.find('default').number_of_boxes
    assert_equal 3, user.boxes.size
    assert_equal 3, Design::Box.count
  end

end
