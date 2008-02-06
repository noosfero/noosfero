require File.join(File.dirname(__FILE__), 'test_helper')


class RoleTest < Test::Unit::TestCase

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

  def test_permission_setting
    role = Role.new(:name => 'permissive_role', :permissions => ['edit_profile'])
    assert role.save
    assert role.has_permission?('edit_profile')
    role.permissions << 'post_content'
    assert role.save
    assert role.has_permission?('post_content')
    assert role.has_permission?('edit_profile')
  end
end
