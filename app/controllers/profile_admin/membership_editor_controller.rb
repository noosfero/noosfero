class MembershipEditorController < ProfileAdminController
  
  def index
    @memberships = current_user.person.memberships
  end

  def new_enteprise
    @enterprise = Enterprise.new()
    @vitual_communities = Environment.find(:all)
    @validation_entities = Organization.find(:all)
  end

  def create_enteprise
    @enterprise = Enterprise.new(params[:enterprise])
    @enterprise.organization_info = OrganizationInfo.new(params[:organization])
    if @enterprise.save
      @enterprise.people << @person
      flash[:notice] = _('The enterprise was succesfully created, the validation entity will cotact you as soon as your enterprise is approved')
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Enterprise was not created')
      @vitual_communities = Environment.find(:all)
      @validation_entities = Organization.find(:all)
      render :action => 'register_form'
    end
  end
  
  # Search enterprises by name or tags
  def search
    @tagged_enterprises = Enterprise.search(params[:query])
  end

end
