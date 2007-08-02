# Manage enterprises by providing an interface to register, activate and manage them
class EnterpriseController < ApplicationController

  before_filter :logon, :my_enterprises
  
  def index
    if @my_enterprises.size == 1
      redirect_to :action => 'show', :id => @my_enterprises[0]
    else
      redirect_to :action => 'list'
    end
  end
  
  def list
    @enterprises = Enterprise.find(:all) - @my_enterprises
    @pending_enterprises = current_user.person.pending_enterprises(false)
  end

  def show
    @enterprise = current_user.person.related_profiles.find(params[:id])
  end
  
  def register_form
    @enterprise = Enterprise.new()
    @vitual_communities = VirtualCommunity.find(:all)
  end

  def register
    @enterprise = Enterprise.new(params[:enterprise])
    @enterprise.organization_info = OrganizationInfo.new(params[:organization])
    if @enterprise.save
      @enterprise.people << current_user.person
      flash[:notice] = _('Enterprise was succesfully created')
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Enterprise was not created')
      render :action => 'register_form'
    end
  end

  def edit
    @enterprise = current_user.person.related_profiles.find(params[:id])
  end

  def update
    @enterprise = current_user.person.related_profiles.find(params[:id])
    if @enterprise.update_attributes(params[:enterprise])
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Could not update the enterprise')
      render :action => 'edit'
    end
  end

  def destroy 
    @enterprise = current_user.person.related_profiles.find(params[:id])
    @enterprise.destroy
    redirect_to :action => 'index'
  end

  protected

  def logon
    redirect_to :controller => 'account' unless logged_in?
  end

  def my_enterprises
    @my_enterprises = current_user.person.enterprises
  end
end
