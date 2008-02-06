module LanguageHelper
  def language
    code = GetText.locale.to_s
  end

  def tinymce_language
    language.downcase
  end

  def language_chooser
    current = language
    Noosfero.locales.map do |code,name|
      if code == current
        content_tag('strong', name)
      else
        link_to(name, :lang => code)
      end
    end.join(' &mdash; ')
  end

end
