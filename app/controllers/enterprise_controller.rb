# Manage enterprises by providing an interface to register, activate and manage them
class EnterpriseController < ApplicationController

  before_filter :logon, :my_enterprises
  
  def index
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

  def show
    @enterprise = @my_enterprises.find{|e| e.id == params[:id]}
  end
  
  protected

  def logon
    redirect_to :controller => 'account' unless logged_in?
  end

  def my_enterprises
    @my_enterprises = current_user.person.my_enterprises
  end
end
