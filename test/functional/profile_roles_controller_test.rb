class ProfileRolesController < ActionController::TestCase

  def setup
    @controller = RoleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @role = Role.find(:first)
    login_as(:ze)
  end

  should 'create a custom role' do
    

  end

  should 'delete a custom role not used' do

  end

  should 'delete a custom role being used' do

  end

  should 'assign a custom role to single user' do

  end

  should  'replace a role with a custom role' do

  end
  role = Role.create!(:name => 'environment_role', :key => 'environment_role', :environment => Environment.default)
end
