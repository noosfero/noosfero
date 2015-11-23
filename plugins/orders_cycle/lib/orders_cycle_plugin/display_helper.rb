module OrdersCyclePlugin::DisplayHelper

  protected

  include ::ActionView::Helpers::JavaScriptHelper # we want the original button_to_function!

  include OrdersPlugin::DisplayHelper

  include OrdersCyclePlugin::RepeatHelper
  include OrdersCyclePlugin::CycleHelper

  include SuppliersPlugin::DisplayHelper
  include SuppliersPlugin::ProductHelper

  include DeliveryPlugin::DisplayHelper

end
