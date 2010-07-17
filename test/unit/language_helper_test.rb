require File.dirname(__FILE__) + '/../test_helper'

class LanguageHelperTest < ActiveSupport::TestCase

  include LanguageHelper

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
    Noosfero.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro', 'fr' => 'Français', 'it' => 'Italiano' }).at_least_once

    self.expects(:language).returns('pt_BR')
    result = self.language_chooser
    assert_match /<strong>Português Brasileiro<\/strong>/, result
    assert_no_match /<strong>English<\/strong>/, result
    assert_no_match /<strong>Français<\/strong>/, result
    assert_no_match /<strong>Italiano<\/strong>/, result

    self.expects(:language).returns('fr')
    result = self.language_chooser
    assert_no_match /<strong>Português Brasileiro<\/strong>/, result
    assert_no_match /<strong>English<\/strong>/, result
    assert_match /<strong>Français<\/strong>/, result
    assert_no_match /<strong>Italiano<\/strong>/, result

  end

  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper
  should 'generate drodown language chooser correcly' do
    Noosfero.expects(:locales).returns({ 'en' => 'English', 'pt_BR' => 'Português Brasileiro', 'fr' => 'Français', 'it' => 'Italiano' }).at_least_once

    self.expects(:language).returns('en')
    result = self.language_chooser(:element => 'dropdown')
    assert_match /<option value="en" selected="selected">English<\/option>/, result
    assert_match /<option value="pt_BR">Português Brasileiro<\/option>/, result
    assert_match /<option value="fr">Français<\/option>/, result
    assert_match /<option value="it">Italiano<\/option>/, result
    assert_no_match /<option value="pt_BR" selected="selected">Português Brasileiro<\/option>/, result
    assert_no_match /<option value="fr" selected="selected">Français<\/option>/, result
    assert_no_match /<option value="it" selected="selected">Italiano<\/option>/, result
  end

  protected

  def _(s)
    s
  end

  def content_tag(tag, text, options = {})
    "<#{tag}>#{text}</#{tag}>"
  end

  def link_to(text, url, options = {})
    "<a href='?lang=#{url[:lang]}'>#{text}</a>"
  end

  def params
    {}
  end

  def url_for(x)
    x.inspect
  end
  
end

