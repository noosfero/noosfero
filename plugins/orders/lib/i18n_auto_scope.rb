
module I18nAutoScope

  extend ActiveSupport::Concern

  included do
    define_method :translate, I18n.method(:translate).to_proc unless self.respond_to? :translate

    alias_method_chain :translate, :auto_scope
    alias_method :t, :translate
  end

  DefaultScope = 'suppliers_plugin'

  # should be replaced on controller (e.g. controller)
  def i18n_scope
    DefaultScope
  end

  protected

  def translate_with_auto_scope key, options = {}
    # raise option is removed from hash, so reinsert each time
    options[:raise] = true
    translation = self.translate_without_auto_scope key, options rescue nil

    unless translation
      Array(i18n_scope).each do |scope|
        options[:scope] = scope
        options[:raise] = true
        return translation if (translation = self.translate_without_auto_scope key, options rescue nil)
      end
    end

    translation
  end

end
