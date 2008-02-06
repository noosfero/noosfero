module LanguageHelper
  def language
    code = GetText.locale.to_s.downcase
    (code == 'en_us') ? 'en' : code
  end
end
