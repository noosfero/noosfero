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
  end

  def show
    @enterprise = @my_enterprises.find(params[:id])
  end
  
  def register_form
    @enterprise = Enterprise.new()
    @vitual_communities = VirtualCommunity.find(:all)
    @validation_entities = Organization.find(:all)
  end

  def register
    @enterprise = Enterprise.new(params[:enterprise])
    @enterprise.organization_info = OrganizationInfo.new(params[:organization])
    if @enterprise.save
      @enterprise.people << @person
      flash[:notice] = _('The enterprise was succesfully created, the validation entity will cotact you as soon as your enterprise is approved')
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Enterprise was not created')
      @vitual_communities = VirtualCommunity.find(:all)
      @validation_entities = Organization.find(:all)
      render :action => 'register_form'
    end
  end

  def edit
    @enterprise = @my_enterprises.find(params[:id])
    @validation_entities = Organization.find(:all) - [@enterprise]
  end

  def update
    @enterprise = @my_enterprises.find(params[:id])
    if @enterprise.update_attributes(params[:enterprise]) && @enterprise.organization_info.update_attributes(params[:organization_info])
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Could not update the enterprise')
      @validation_entities = Organization.find(:all) - [@enterprise]
      render :action => 'edit'
    end
  end

  def affiliate
    @enterprise = Enterprise.find(params[:id])
    @enterprise.people << @person
    redirect_to :action => 'index'
  end

  def destroy 
    @enterprise = @my_enterprises.find(params[:id])
    @enterprise.destroy
    redirect_to :action => 'index'
  end
  
  def search
    @tagged_enterprises = Enterprise.search(params[:query])
  end

  def activate
    @enterprise = Enterprise.find(params[:id])
    if @enterprise.update_attribute('active', true)
      flash[:notice] = 'Enterprise successfuly activacted'
      render :action => 'show'
    else
      redirect_to :action => 'show', :id => @enterprise
    end
  end

  protected

  def logon
    if logged_in?
      @user = current_user
      @person = @user.person
    else
      redirect_to :controller => 'account' unless logged_in?
    end
  end

  def my_enterprises
    if logged_in?
      @my_active_enterprises = @person.active_enterprises
      @my_pending_enterprises = @person.pending_enterprises
      @my_enterprises = @person.enterprises
    end
  end
end
