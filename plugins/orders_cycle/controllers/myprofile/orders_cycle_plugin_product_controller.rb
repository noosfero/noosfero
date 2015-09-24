class OrdersCyclePluginProductController < SuppliersPlugin::ProductController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::DisplayHelper

  def edit
    super
    @units = environment.units.all
  end

  def remove_from_order
    @offered_product = OrdersCyclePlugin::OfferedProduct.find params[:id]
    @order = OrdersCyclePlugin::Sale.find params[:order_id]
    raise 'Order confirmed or cycle is closed for orders' unless @order.open?
    @item = @order.items.find_by_product_id @offered_product.id
    @item.destroy rescue render nothing: true
  end

  def cycle_edit
    @product = OrdersCyclePlugin::OfferedProduct.find params[:id]
    if request.xhr?
      @product.update_attributes! params[:product]
      respond_to do |format|
        format.js
      end
    end
  end

  def cycle_destroy
    @product = OrdersCyclePlugin::OfferedProduct.find params[:id]
    @product.destroy
    flash[:notice] = t('controllers.myprofile.product_controller.product_removed_from_')
  end

  protected

  extend HMVC::ClassMethods
  hmvc OrdersCyclePlugin, orders_context: OrdersCyclePlugin

end
