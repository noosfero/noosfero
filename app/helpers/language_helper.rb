module LanguageHelper
  def language
    if Noosfero.available_locales.include?(locale.to_s) ||
      Noosfero.available_locales.include?(locale.language)
      locale.language
    else
      Noosfero.default_locale || 'en'
    end
  end

  def tinymce_language
    language.downcase.split('_').first
  end

  def html_language
    language.downcase.gsub('_', '-')
  end

  alias :calendar_date_select_language :tinymce_language

  def language_chooser(options = {})
    current = language
    separator = options[:separator] || ' &mdash; '

    if options[:element] == 'dropdown'
      select_tag('lang', 
        options_for_select(Noosfero.locales.map{|code,name| [name, code]}, current),
        :onchange => "document.location.href= #{url_for(params.merge(:lang => 'LANGUAGE')).inspect}.replace(/LANGUAGE/, this.value) ;",
        :help => _('The language you choose here is the language used for options, buttons, etc. It does not affect the language of the content created by other users.')
      )
    else
      languages = Noosfero.locales.map do |code,name|
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
