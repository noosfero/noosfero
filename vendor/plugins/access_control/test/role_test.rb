require File.join(File.dirname(__FILE__), 'test_helper')


class RoleTest < Test::Unit::TestCase

  def setup
    Role.delete_all
  end

  def test_role_creation
    count = Role.count
    role = Role.new(:name => 'any_role')
    assert role.save
    assert_equal count + 1, Role.count
  end
  
  def test_uniqueness_of_name
    Role.create(:name => 'role_name')
    role = Role.new(:name => 'role_name')
    assert ! role.save    
  end

  def test_uniqueness_of_key
    Role.create!(:name => 'unique key', :key => 'my_key')
    role = Role.new(:key => 'my_key'); role.valid?
    assert role.errors.invalid?(:key)
  end

  def test_permission_setting
    role = Role.new(:name => 'permissive_role', :permissions => ['edit_profile'])
    assert role.save
    assert role.has_permission?('edit_profile')
    role.permissions << 'post_content'
    assert role.save
    assert role.has_permission?('post_content')
    assert role.has_permission?('edit_profile')
  end

  def test_should_translate_name_if_gettext_is_being_used
    role = Role.new(:name => 'my name')
    Role.expects(:included_modules).returns(['GetText'])
    role.expects(:gettext).with('my name').returns('meu nome')

    assert_equal 'meu nome', role.name
  end

  def test_should_not_try_gettext_if_not_being_used
    Role.expects(:included_modules).returns([])
    role = Role.new(:name => 'my name')
    role.expects(:gettext).never
    assert_equal 'my name', role.name
  end

  def test_should_remove_non_system_defined_roles_normally
    role = Role.create!(:name => 'to be removed', :permissions => [], :system => false)
    count = Role.count
    role.destroy
    assert_equal count - 1, Role.count
  end

  def test_should_not_allow_to_remove_system_defined_roles

    role = Role.create!(:name => 'not to be removed', :permissions => [], :system => true)

    count = Role.count
    role.destroy
    assert_equal count, Role.count

  end

  def test_should_have_an_empty_array_as_permissions_by_default
    role = Role.new
    assert_equal [], role.permissions
  end

end
