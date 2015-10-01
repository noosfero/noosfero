module SuppliersPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def i18n_scope
    ['suppliers_plugin']
  end

end
