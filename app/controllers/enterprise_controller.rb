# Manage enterprises by providing an interface to register, activate and manage them
class EnterpriseController < ApplicationController

  def index
    @my_enterprises = current_user.enterprises if current_user
    @enterprises = Enterprise.find(:all) - @my_enterprises
  end
  
  def register_form
    redirect_to :controller => 'account' unless logged_in?
    @enterprise = Enterprise.new()
    @vitual_communities = VirtualCommunity.find(:all)
  end

  def register
    @enterprise = Enterprise.new(params[:enterprise])
    @enterprise.manager_id = current_user.id
    if @enterprise.save
      @enterprise.users << current_user
      flash[:notice] = _('Enterprise was succesfully created')
      redirect_to :action => 'index'
    else
      flash[:notice] = _('Enterprise was not created')
      render :action => 'register'
    end
  end
end
