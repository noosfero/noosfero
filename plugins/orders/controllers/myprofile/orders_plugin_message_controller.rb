class OrdersPluginMessageController < MyProfileController

  no_design_blocks

  #protect 'edit_profile', :profile

  include OrdersPlugin::TranslationHelper

  helper OrdersPlugin::TranslationHelper
  helper OrdersPlugin::FieldHelper

  def new_to_admins
    @member = user
    if params[:commit]
      OrdersPlugin::Mailer.message_to_admins(profile, @member, params[:email][:subject], params[:email][:message]).deliver
      page_reload
    end
  end

  def new_to_supplier
    @order = profile.purchases.find params[:order_id]
    @supplier = @order.profile
    if params[:commit]
      options = {order: @order, include_order: params[:include_order]}
      OrdersPlugin::Mailer.message_to_supplier(profile, @supplier, params[:email][:subject], params[:email][:message], options).deliver
      page_reload
    end
  end

  def new_to_consumer
    @order = profile.sales.find params[:order_id]
    if params[:commit]
      options = {order: @order, include_order: params[:include_order]}
      OrdersPlugin::Mailer.message_to_consumer(profile, @order.consumer, params[:email][:subject], params[:email][:message], options).deliver
      page_reload
    end
  end

  protected

  def page_reload
    session[:notice] = t'orders_cycle_plugin.controllers.myprofile.message_controller.message_sent'
    respond_to do |format|
      format.js { render partial: 'orders_plugin_shared/pagereload' }
    end
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin, orders_context: OrdersPlugin

end
