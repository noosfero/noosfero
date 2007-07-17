class FeaturesController < ApplicationController
  acts_as_virtual_community_admin_controller

  def index
    @features = VirtualCommunity.available_features
  end

  def update
    @virtual_community.enabled_features = params[:features].keys
    @virtual_community.save!
    flash[:notice] = _('Features updated successfully.')
    redirect_to :action => 'index'
  end

end
