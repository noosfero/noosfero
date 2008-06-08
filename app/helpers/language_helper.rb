module LanguageHelper
  def language
    code = GetText.locale.to_s
  end

  def tinymce_language
    language.downcase
  end

  alias :calendar_date_select_language :tinymce_language

  def language_chooser(options = {})
    current = language
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
          link_to(name, :lang => code)
        end
      end.join(' &mdash; ')
      content_tag('div', languages, :id => 'language-chooser', :help => _('The language you choose here is the language used for options, buttons, etc. It does not affect the language of the content created by other users.'))
    end
  end

end
