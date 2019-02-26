class OrdersPluginOrderController < ProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  before_action :login_required, except: [:index, :edit]
  before_action :load_order, except: [:new]
  before_action :check_access, only: [:confirm, :remove, :cancel]
  before_action :set_actor_name
  before_action :disable_purechat

  helper OrdersPlugin::TranslationHelper
  helper OrdersPlugin::DisplayHelper

  def repeat
  end

  protected

  def load_order
    @order = hmvc_orders_context::Sale.find_by id: params[:id]
    render_access_denied if @order.present? and (not @user_is_admin or not @order.may_view? user)
  end

  def check_access access = 'view'
    unless @order.send "may_#{access}?", user
      session[:notice] = if user.blank? then t('orders_plugin.controllers.profile.consumer.login_first') else session[:notice] = t('orders_plugin.controllers.profile.consumer.you_are_not_the_owner') end
      redirect_to action: :index
      false
    else
      true
    end
  end

  # default value, may be overwriten
  def set_actor_name
    @actor_name = :consumer
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin, orders_context: OrdersPlugin

  def disable_purechat
    @disable_purechat = true
  end

end
