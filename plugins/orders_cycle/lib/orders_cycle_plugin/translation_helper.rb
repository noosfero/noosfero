module OrdersCyclePlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def i18n_scope
    ['orders_cycle_plugin', 'orders_plugin', 'suppliers_plugin', 'volunteers_plugin']
  end

end
