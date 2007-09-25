class MembershipEditorController < ProfileAdminController
  
  def index
    @memberships = current_user.person.memberships
  end
end
