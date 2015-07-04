# encoding: UTF-8
require_relative "../test_helper"

class LanguageHelperTest < ActiveSupport::TestCase

  include LanguageHelper

  def link_to(name, url, options = {})
    name
  end

  def url_for(url)
    ''
  end

  should 'return current language' do
    expects(:locale).returns('pt')
    assert_equal 'pt', language
  end

  should 'remove country code for TinyMCE' do
    self.expects(:language).returns('pt_BR')
    assert_equal 'pt', tinymce_language
  end

  should 'downcase and use dash for HTML language' do
    self.expects(:language).returns('pt_BR')
    assert_equal 'pt-br', html_language
  end

  should 'generate language chooser correcly' do
    environment = Environment.default
    environment.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro', 'fr' => 'Français', 'it' => 'Italiano' }).at_least_once

    self.expects(:language).returns('pt_BR')
    result = self.language_chooser(environment)
    assert_match /<strong>Português Brasileiro<\/strong>/, result
    assert_no_match /<strong>English<\/strong>/, result
    assert_no_match /<strong>Français<\/strong>/, result
    assert_no_match /<strong>Italiano<\/strong>/, result

    self.expects(:language).returns('fr')
    result = self.language_chooser(environment)
    assert_no_match /<strong>Português Brasileiro<\/strong>/, result
    assert_no_match /<strong>English<\/strong>/, result
    assert_match /<strong>Français<\/strong>/, result
    assert_no_match /<strong>Italiano<\/strong>/, result
  end

  should 'generate drodown language chooser correcly' do
    environment = Environment.default
    environment.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro', 'fr' => 'Français', 'it' => 'Italiano' }).at_least_once

    self.expects(:language).returns('en')
    result = self.language_chooser(environment, :element => 'dropdown')
    assert_match /<option selected="selected" value="en">English<\/option>/, result
    assert_match /<option value="pt_BR">Português Brasileiro<\/option>/, result
    assert_match /<option value="fr">Français<\/option>/, result
    assert_match /<option value="it">Italiano<\/option>/, result
    assert_no_match /<option value="pt_BR" selected="selected">Português Brasileiro<\/option>/, result
    assert_no_match /<option value="fr" selected="selected">Français<\/option>/, result
    assert_no_match /<option value="it" selected="selected">Italiano<\/option>/, result
  end

  should 'not list languages if there is less than 2 languages available' do
    environment = Environment.default

    environment.expects(:locales).returns({ 'en' => 'English'}).at_least_once
    result = self.language_chooser(environment)
    assert result.blank?

    environment.expects(:locales).returns({}).at_least_once
    result = self.language_chooser(environment)
    assert result.blank?
  end

  should 'get noosfero locales if environment is not defined' do
    self.expects(:language).returns('en')
    Noosfero.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro' }).at_least_once
    result = self.language_chooser
    assert_match /Português Brasileiro/, result
    assert_match /English/, result
  end

  should 'get noosfero locales if environment is not defined and has options' do
    self.expects(:language).returns('en')
    Noosfero.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro' }).at_least_once
    result = self.language_chooser(nil, :separator=>"<span class=\"language-separator\"/>")
    assert_match /Português Brasileiro/, result
    assert_match /English/, result
  end

  protected
  include NoosferoTestHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper

end
