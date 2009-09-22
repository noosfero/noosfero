def language_to_header(name)
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

def language_to_code(name)
   language_to_header(name)
end

Given /^Noosfero is configured to use (.+) as default$/ do |lang|
  Noosfero.default_locale = language_to_code(lang)
end

After('@default_locale_config') do
  Noosfero.default_locale = nil
  GetText.locale = nil
end

Given /^a user accessed in (.*) before$/ do |lang|
  session = Webrat::Session.new(Webrat.adapter_class.new(self))
  session.extend(Webrat::Matchers)
  session.visit('/')
  session.should have_selector('html[lang=en]')
end

Given /^my browser prefers (.*)$/ do |lang|
  @n ||= 0
  header 'Accept-Language', language_to_header(lang)

end

Then /^the site should be in (.*)$/ do |lang|
  response.should have_selector("html[lang=#{language_to_code(lang)}]")
  response.body.should match(/<strong>#{native_name(lang)}<\/strong>/)
end

