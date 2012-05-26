require 'fast_gettext'

class Object
  include FastGettext::Translation
  alias :gettext :_
  alias :ngettext :n_
end

# translations in place?
locale_dir = Rails.root.join('locale')
repos = []
if File.exists?(locale_dir)
  repos << FastGettext::TranslationRepository.build('noosfero', :type => 'mo', :path => locale_dir)
  repos << FastGettext::TranslationRepository.build('iso_3166', :type => 'mo', :path => locale_dir)
end

FastGettext.add_text_domain 'noosferofull', :type => :chain, :chain => repos
FastGettext.default_text_domain = 'noosferofull'
