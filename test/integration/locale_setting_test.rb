require "#{File.dirname(__FILE__)}/../test_helper"

class LocaleSettingTest < ActionController::IntegrationTest

  should 'set locale properly' do

    # set locale to pt_BR
    get '/', :locale => 'pt_BR'
    assert_equal 'pt_BR', GetText.locale.to_s

    # locale is kept
    get '/'
    assert_equal 'pt_BR', GetText.locale.to_s

    # changing back
    get '/', :locale => 'en'
    assert_equal 'en', GetText.locale.to_s

    # locale is kept again
    get '/'
    assert_equal 'en', GetText.locale.to_s

  end


end
