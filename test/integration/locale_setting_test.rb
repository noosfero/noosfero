require "#{File.dirname(__FILE__)}/../test_helper"

class LocaleSettingTest < ActionController::IntegrationTest

  def setup
    # reset GetText before every test
    GetText.locale = nil
    Noosfero.stubs(:default_locale).returns('en')
    Noosfero.stubs(:available_locales).returns(['pt_BR'])
  end

  should 'be able to set a default language' do
    Noosfero.expects(:default_locale).returns('pt_BR').at_least_once

    get '/'
    assert_locale 'pt_BR'
  end

  should 'detect locale from the browser' do

    # user has pt_BR
    get '/', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'pt-br, en' }
    assert_locale 'pt_BR'

    # user now wants en
    get '/', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'en' }
    assert_locale 'en'
  end

  should 'not use unsupported browser-informed locale and use C instead' do
    get '/', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'xx-yy, pt-br, en' }
    assert_locale 'en'
  end

  should 'fallback to similar languages' do
    # FIXME this assumes pt_PT is unsupported. If a pt_PT translation is added
    # this test will break.
    get '/', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'pt-pt, en' }
    assert_locale 'pt_BR'
  end

  should 'accept language without country code and pick a suitable language' do
    get '/', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'pt, en'}
    assert_locale 'pt_BR'
  end

  should 'be able to force locale' do

    # set locale to pt_BR
    get '/', :lang => 'pt_BR'
    assert_locale 'pt_BR'

    # locale is kept
    get '/'
    assert_locale 'pt_BR'

    # changing back
    get '/', :lang => 'en'
    assert_locale 'en'

    # locale is kept again
    get '/'
    assert_locale 'en'

  end

  should 'put current language in HTML headers' do
    get '/', :lang => 'pt_BR'
    assert_tag :tag => 'html', :attributes => { 'xml:lang' => 'pt-br', 'lang' => 'pt-br' }

    get '/', :lang => 'en'
    assert_tag :tag => 'html', :attributes => { 'xml:lang' => 'en', 'lang' => 'en' }
  end

  protected 

  def assert_locale(locale)
    gettext_locale = GetText.locale.to_s
    ok("Ruby-GetText locale should be #{locale}, but was #{gettext_locale}") { locale == gettext_locale }

    # TODO this test depends on a unpublished patch to liblocale-ruby
    #system_locale = Locale.getlocale
    #wanted_system_locale = 
    #  if locale == 'en'
    #    'C'
    #  else
    #    '%s.utf8' % locale
    #  end

    #ok("System locale should be #{wanted_system_locale}, but was #{system_locale}") { wanted_system_locale == system_locale }
  end
  
end
