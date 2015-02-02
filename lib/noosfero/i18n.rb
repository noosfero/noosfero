require 'fast_gettext'

class Object
  include FastGettext::Translation
  alias :gettext :_
  alias :ngettext :n_
  alias :c_ :_
  alias :cN_ :N_
end


# Adds custom locales for a whole environment
custom_locale_dir = Rails.root.join('config', 'custom_locales', Rails.env)
repos = []
if File.exists?(custom_locale_dir)
  repos << FastGettext::TranslationRepository.build('environment', :type => 'po', :path => custom_locale_dir)
end

Dir.glob('{baseplugins,config/plugins}/*/locale') do |plugin_locale_dir|
  plugin = File.basename(File.dirname(plugin_locale_dir))
  repos << FastGettext::TranslationRepository.build(plugin, :type => 'mo', :path => plugin_locale_dir)
end

# translations in place?
locale_dir = Rails.root.join('locale')
if File.exists?(locale_dir)
  repos << FastGettext::TranslationRepository.build('noosfero', :type => 'mo', :path => locale_dir)
  repos << FastGettext::TranslationRepository.build('iso_3166', :type => 'mo', :path => locale_dir)
end

FastGettext.add_text_domain 'noosfero', :type => :chain, :chain => repos
FastGettext.default_text_domain = 'noosfero'

# Adds custom locales for specific domains; Domains are identified by the
# sequence before the first dot, while tenants are identified by schema name
hosted_environments = Noosfero::MultiTenancy.mapping.values
hosted_environments += Domain.all.map { |domain| domain.name[/(.*?)\./,1] } if Domain.table_exists?

hosted_environments.uniq.each do |env|
  custom_locale_dir = Rails.root.join('config', 'custom_locales', env)
  if File.exists?(custom_locale_dir)
    FastGettext.add_text_domain(env, :type => :chain, :chain => [FastGettext::TranslationRepository.build('environment', :type => 'po', :path => custom_locale_dir)] + repos)
  end
end
