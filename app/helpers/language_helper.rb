module LanguageHelper
  def language
    locale.to_s
  end

  def tinymce_language
    language.downcase.split('_').first
  end

  def html_language
    language.downcase.gsub('_', '-')
  end

  alias :calendar_date_select_language :tinymce_language

  def language_chooser(environment=nil, options = {})
    locales = environment.nil? ? Noosfero.locales : environment.locales
    return if locales.size < 2
    current = language
    separator = options[:separator] || ' &mdash; '

    if options[:element] == 'dropdown'
      select_tag('lang',
        options_for_select(locales.map{|code,name| [name, code]}, current),
        :onchange => "document.location.href= #{url_for(params.merge(:lang => 'LANGUAGE'))}.replace(/LANGUAGE/, this.value) ;",
        :help => _('The language you choose here is the language used for options, buttons, etc. It does not affect the language of the content created by other users.')
      )
    else
      languages = locales.map do |code,name|
        if code == current
          content_tag('strong', name)
        else
          link_to(name, params.merge(:lang => code), :rel => 'nofollow')
        end
      end.join(separator)
      content_tag('div', languages, :id => 'language-chooser', :help => _('The language you choose here is the language used for options, buttons, etc. It does not affect the language of the content created by other users.'))
    end
  end

end
