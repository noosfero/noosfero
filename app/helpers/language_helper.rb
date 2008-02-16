module LanguageHelper
  def language
    code = GetText.locale.to_s
  end

  def tinymce_language
    language.downcase
  end

  def language_chooser
    current = language
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
