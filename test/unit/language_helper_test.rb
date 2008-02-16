require File.dirname(__FILE__) + '/../test_helper'

class LanguageHelperTest < Test::Unit::TestCase

  include LanguageHelper

  should 'return current language' do
    locale = mock
    locale.expects(:to_s).returns('pt_BR')
    GetText.stubs(:locale).returns(locale)

    assert_equal 'pt_BR', self.language
  end

  should 'downcase language for tinymce' do
    self.expects(:language).returns('pt_BR')
    assert_equal 'pt_br', tinymce_language
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

  protected

  def _(s)
    s
  end

  def content_tag(tag, text, options = {})
    "<#{tag}>#{text}</#{tag}>"
  end

  def link_to(text, opts)
    "<a href='?lang=#{opts[:lang]}'>#{text}</a>"
  end

end

