require File.join(File.dirname(__FILE__), 'test_helper')


class RoleTest < Test::Unit::TestCase

  def setup
    RoleAssignment.attr_accessible :role, :accessor
    Role.attr_accessible :system
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
    assert role.errors.include?(:key)
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

  def test_should_not_allow_changing_key_of_system_roles
    role = Role.create!(:name => 'a test role', :system => true, :key => 'some_unprobable_key')

    assert_raise(ArgumentError) do
      role.key = 'another_key'
    end
    assert_equal 'some_unprobable_key', role.key
  end

  def test_should_allow_changing_key_of_non_system_role
    role = Role.create!(:name => 'a test role', :system => false, :key => 'some_unprobable_key')

    assert_nothing_raised do
      role.key = 'another_key'
    end
    assert_equal 'another_key', role.key
  end

  def test_should_have_kind
    role = Role.create!(:name => 'a test role', :permissions => ['perm1'])
    role.stubs(:perms).returns({'kind1' => {'perm1' => 'perm1 name', 'perm2' => 'perm2 name'}, 'kind2' => {'perm3' => 'perm3 name'}})

    assert role.has_kind?('kind1')
    assert ! role.has_kind?('kind2')
    assert ! role.has_kind?('kind3')
  end

  def test_should_destroy_associated_role_assignments
    role = Role.create!(:name => 'a test role', :permissions => ['perm1'])
    ra = RoleAssignment.create!(:role => role, :accessor => AccessControlTestAccessor.create(:name => 'accessor'))

    role.destroy

    assert !RoleAssignment.exists?(ra.id)
  end

  def test_should_define_key_for_role_if_key_not_present
    r = Role.create! :name => 'Test Role'
    assert_equal 'profile_test_role', r.key
  end

  def test_should_not_define_key_for_role_if_key_present
    r = Role.create! :name => 'Test Role', :key => 'foo'
    assert_equal 'foo', r.key
  end

end
