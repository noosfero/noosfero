# Manage enterprises by providing an interface to register, activate and manage them
class EnterprisesController < ApplicationController

  def register_form
    @vitual_communities = VirtualCommunity.find(:all)
  end

  def create
    @enterprise = Enterprise.new(params[:enterprise])
    if @enterprise.save
      redirect_to :action => 'choose_validation_entity_or_net'
    else
      render :action => 'register_form'
    end
  end

  def choose_validation_entity_or_net
#    @options = Entity_or_Net.find(:all))
  @options = ['a', 'b', 'c']
  end
end
