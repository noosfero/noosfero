# Manage enterprises by providing an interface to register, activate and manage them
class EnterpriseController < ProfileAdminController

  before_filter :logon, :my_enterprises
  protect([:edit, :update, :activate, :destroy], 'edit_enterprise', @profile)

  # Redirects to show if there is only one action and to list otherwise
  def index
    if @person.enterprises.size == 1
      redirect_to :action => 'show', :id => @person.enterprises[0]
    else
      redirect_to :action => 'list'
    end
    @vitual_communities = Environment.find(:all)
    @validation_entities = Organization.find(:all)
  end
  
  # Lists all enterprises
  def list
    @enterprises = Enterprise.find(:all) - @person.enterprises
  end

  # Show details about an enterprise
  def show
    @enterprise = Enterprise.find(params[:id])
  end
  
  # Make a form to the creation of an eterprise
  def register_form
    @enterprise = Enterprise.new()
    @vitual_communities = Environment.find(:all)
    @validation_entities = Organization.find(:all)
  end

  # Saves the new created enterprise
  def register
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

  # Provides an interface to editing the enterprise details
  def edit
    @enterprise = @person.enterprises(:id => params[:id])[0]
    @validation_entities = Organization.find(:all) - [@enterprise]
  end

  # Saves the changes made in an enterprise
  def update
    @enterprise = @person.enterprises(:id => params[:id])[0]
    if @enterprise.update_attributes(params[:enterprise]) && @enterprise.organization_info.update_attributes(params[:organization_info])
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Could not update the enterprise')
      @validation_entities = Organization.find(:all) - [@enterprise]
      render :action => 'edit'
    end
  end

  # Make the current user a new member of the enterprise
  def affiliate
    @enterprise = Enterprise.find(params[:id])
    member_role = Role.find_by_name('member') || Role.create(:name => 'member')
    @enterprise.affiliate(@person,member_role)
    redirect_to :action => 'index'
  end

  # Elimitates the enterprise of the system
  def destroy 
    @enterprise = @person.enterprises(:id => params[:id])[0]
    if @enterprise
      @enterprise.destroy
    else
      flash[:notice] = 'Can destroy only your enterprises'
    end
    redirect_to :action => 'index'
  end
  
  # Search enterprises by name or tags
  def search
    @tagged_enterprises = Enterprise.search(params[:query])
  end

  # Activate a validated enterprise
  def activate
    @enterprise = Enterprise.find(params[:id])
    if @enterprise.activate
      flash[:notice] = _('Enterprise successfuly activacted')
    else
      flash[:notice] = _('Failed to activate the enterprise')
    end
    redirect_to :action => 'index'
  end

  # Validates an eterprise
  def approve
    @enterprise = Enterprise.find(params[:id])
    if @enterprise.approve
      flash[:notice] = _('Enterprise successfuly approved')
    else
      flash[:notice] = _('Failed to approve the htmlenterprise')
    end
    redirect_to :action => 'index'
  end

  # Rejects an enterprise
  def reject
    @enterprise = Enterprise.find(params[:id])
    if @enterprise.reject
      flash[:notice] = _('Enterprise successfuly rejected')
    else
      flash[:notice] = _('Failed to reject the enterprise')
    end
    redirect_to :action => 'index'
  end
    

  protected

  # Make sure that the user is logged before access this controller
  def logon
    if logged_in?
      @user = current_user
      @person = @user.person
    else
      redirect_to :controller => 'account' unless logged_in?
    end
  end

  # Initializes some variables to contain the enterprises of the current user
  def my_enterprises
    if logged_in?
      @my_active_enterprises = @person.active_enterprises
      @my_pending_enterprises = @person.pending_enterprises
      @my_enterprises = @person.enterprises
    end
  end
end
