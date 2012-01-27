require File.dirname(__FILE__) + '/../test_helper'

class NoosferoI18nTest < ActiveSupport::TestCase

  Noosfero.available_locales.each do |locale|
    next if locale == 'en'
    should('have locale file for %s' % locale) do
      locale_file = 'config/locales/%s.yml' % locale
      assert File.exists?(File.join(Rails.root, locale_file)), "#{locale_file} not found"
    end

  end

end
