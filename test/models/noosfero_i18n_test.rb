require_relative "../test_helper"

class NoosferoI18nTest < ActiveSupport::TestCase

  def setup
    @locale = I18n.locale
  end

  def teardown
    I18n.locale = @locale
  end

  Noosfero.available_locales.each do |locale|

    next if locale == 'en'

    should('have locale file for %s' % locale) do
      locale_file = 'config/locales/%s.yml' % locale
      assert File.exists?(Rails.root.join(locale_file)), "#{locale_file} not found"
    end

    should('be able to translate activerecord errors header to %s' % locale) do
      I18n.locale = locale
      translation = I18n.translate 'activerecord.errors.template.header.one'
      assert translation !~ /translation missing/, "Missing translation for activerecord.errors.template.header.one to #{Noosfero.locales[locale]}"
    end

  end

end
