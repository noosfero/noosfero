# -*- coding: utf-8 -*-
def language_to_code(name)
  {
    'Brazilian Portuguese' => 'pt-br',
    'European Portuguese' => 'pt-pt',
    'Portuguese' => 'pt',
    'French' => 'fr',
    'English' => 'en',
    'Japanese' => 'ja',
    'Klingon' => 'tlh' # http://en.wikipedia.org/wiki/Klingon_language
  }[name]
end

def native_name(name)
  {
    'Portuguese' => 'Português',
    'French' => 'Français',
  }[name] || name
end

Given /^Noosfero is configured to use (.+) as default$/ do |lang|
  Noosfero.default_locale = language_to_code(lang)
end

Given /^the following languages "([^"]*)" are available on environment$/ do |languages|
  Environment.default.update_attribute(:languages, languages.split)
end

After do
  # reset everything back to normal
  Noosfero.default_locale = nil
  FastGettext.locale = 'en'
end

Given /^a user accessed in (.*) before$/ do |lang|
  session = Webrat::Session.new(Webrat.adapter_class.new(self))
  session.extend(Webrat::Matchers)
  session.visit('/')
  session.should have_selector("html[lang=#{language_to_code(lang)}]")
end

Given /^my browser prefers (.*)$/ do |lang|
  page.driver.header 'Accept-Language', language_to_code(lang)
end

Then /^the site should be in (.*)$/ do |lang|
  page.should have_selector("html[lang=#{language_to_code(lang)}]")
  page.body.should match(/<strong>#{native_name(lang)}<\/strong>/)
end

