class OrdersCyclePluginVolunteersController < VolunteersPluginMyprofileController

  no_design_blocks
  include OrdersCyclePlugin::TranslationHelper

  helper OrdersCyclePlugin::TranslationHelper

  protected

  extend HMVC::ClassMethods
  hmvc OrdersCyclePlugin, orders_context: OrdersCyclePlugin

end
