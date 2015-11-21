require_dependency 'delivery_plugin/display_helper'

class DeliveryPlugin::AdminMethodController < MyProfileController

  protect 'edit_profile', :profile

  helper OrdersPlugin::FieldHelper
  helper DeliveryPlugin::DisplayHelper

  def new
    @delivery_method = profile.delivery_methods.build
    self.edit
  end

  def edit
    @delivery_method ||= profile.delivery_methods.find_by_id params[:id]
    if params[:delivery_method].present? and @delivery_method.update params[:delivery_method]
      render partial: 'list'
    else
      render partial: 'edit', locals: {delivery_method: @delivery_method}
    end
  end

  def destroy
    @delivery_method = profile.delivery_methods.find params[:id]
    @delivery_method.destroy
    render nothing: true
  end

  protected

end
