require "#{File.dirname(__FILE__)}/../test_helper"

class LocaleSettingTest < ActionController::IntegrationTest

  def setup
    # reset GetText before every test
    GetText.locale = nil
  end

  should 'detect locale from the browser' do

    # user has pt_BR
    get '/', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'pt-br, en' }
    assert_equal 'pt_BR', GetText.locale.to_s

    # user now wants en
    get '/', { }, { 'HTTP_ACCEPT_LANGUAGE' => 'en' }
    assert_equal 'en', GetText.locale.to_s

  end

  should 'be able to force locale' do

    # set locale to pt_BR
    get '/', :lang => 'pt_BR'
    assert_equal 'pt_BR', GetText.locale.to_s

    # locale is kept
    get '/'
    assert_equal 'pt_BR', GetText.locale.to_s

    # changing back
    get '/', :lang => 'en'
    assert_equal 'en', GetText.locale.to_s

    # locale is kept again
    get '/'
    assert_equal 'en', GetText.locale.to_s

  end



end
