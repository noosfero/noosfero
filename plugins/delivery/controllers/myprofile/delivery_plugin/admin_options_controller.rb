class DeliveryPlugin::AdminOptionsController < DeliveryPlugin::AdminMethodController

  helper OrdersPlugin::FieldHelper
  helper DeliveryPlugin::DisplayHelper

  protect 'edit_profile', :profile
  before_filter :load_context
  before_filter :load_owner

  def select
  end

  def select_all
    missing_methods = profile.delivery_methods - @owner.delivery_methods
    missing_methods.each do |dm|
      DeliveryPlugin::Option.create! owner_id: @owner.id, owner_type: @owner.class.name, delivery_method: dm
    end
  end

  def new
    dms = profile.delivery_methods.find Array(params[:method_id])
    (dms - @owner.delivery_methods).each do |dm|
      DeliveryPlugin::Option.create! owner_id: @owner.id, owner_type: @owner.class.name, delivery_method: dm
    end
  end

  def destroy
    @delivery_option = @owner.delivery_options.find params[:id]
    @delivery_option.destroy
  end

  protected

  def load_owner
    @owner_id = params[:owner_id]
    @owner_type = params[:owner_type]
    @owner = @owner_type.constantize.find @owner_id
  end

  def load_context
    @delivery_context = 'delivery_plugin/admin_options'
  end

end
