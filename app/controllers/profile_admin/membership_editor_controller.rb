class MembershipEditorController < ProfileAdminController
  
  def index
    @memberships = Profile.find(:all, :include => 'role_assignments', :conditions => ['role_assignments.person_id = ?', current_user.person.id])
  end
end
