require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  all_fixtures

  def test_role_creation
    assert_difference Role, :count do
      role = Role.new(:name => 'new_role')
      assert role.save
    end
  end
  
  def test_uniqueness_of_name
    Role.create(:name => 'role_name')
    role = Role.new(:name => 'role_name')
    assert ! role.save    
  end

  def test_name_of_permission
    assert_equal 'Edit profile', Role.permission_name('edit_profile')
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

  def test_permission_existece
    role = Role.new(:name => 'role_with_non_existent_permission')
    role.permissions << 'non_existent_permission'
    assert ! role.save
  end
end
