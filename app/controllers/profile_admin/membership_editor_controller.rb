class MembershipEditorController < ProfileAdminController

  before_filter :login_required

  needs_profile 
 
  protect [:index, :new_enterprise, :create_enterprise ], 'edit_profile', profile

  def index
    @memberships = current_user.person.memberships
  end

  def new_enterprise
    @enterprise = Enterprise.new()
    @validation_entities = Organization.find(:all)
  end

  def create_enterprise
    @enterprise = Enterprise.new(params[:enterprise])
    @enterprise.organization_info = OrganizationInfo.new(params[:organization])
    if @enterprise.save
      @enterprise.affiliate(current_user.person, Role.find(:all, :conditions => {:name => ['owner', 'member', 'moderator']}))
      flash[:notice] = _('The enterprise was successfully created, the validation entity will cotact you as soon as your enterprise is approved')
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Enterprise was not created')
      @validation_entities = Organization.find(:all)
      render :action => 'register_form'
    end
  end
  
  # Search enterprises by name or tags
  def search
    @tagged_enterprises = Enterprise.search(params[:query])
  end

end
