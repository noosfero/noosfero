module LanguageHelper
  def language
    code = GetText.locale.to_s.downcase
    if code == 'en_us'
      'en'
    else
      code
    end
  end
end
