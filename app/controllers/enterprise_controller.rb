# Manage enterprises by providing an interface to register, activate and manage them
class EnterpriseController < ApplicationController

  before_filter :logon
  
  def index
    @my_enterprises = current_user.person.my_enterprises
    @enterprises = Enterprise.find(:all) - @my_enterprises
  end
  
  def register_form
    @enterprise = Enterprise.new()
    @vitual_communities = VirtualCommunity.find(:all)
  end

  def register
    @enterprise = Enterprise.new(params[:enterprise])
    if @enterprise.save
      @enterprise.people << current_user.person
      flash[:notice] = _('Enterprise was succesfully created')
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Enterprise was not created')
      render :action => 'register'
    end
  end

  protected

  def logon
    redirect_to :controller => 'account' unless logged_in?
  end
end
