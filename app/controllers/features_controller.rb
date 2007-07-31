class FeaturesController < ApplicationController


  # FIXME: temp test code, remove from here
  design :holder => 'virtual_community'
  def test
    render :inline => '<%= design_display("bli") %>'
  end
  ################################

  acts_as_virtual_community_admin_controller

  def index
    @features = VirtualCommunity.available_features
  end

  post_only :update
  def update
    features = if params[:features].nil?
                 []
               else
                 params[:features].keys
               end
    @virtual_community.enabled_features = features
    @virtual_community.save!
    flash[:notice] = _('Features updated successfully.')
    redirect_to :action => 'index'
  end

end
