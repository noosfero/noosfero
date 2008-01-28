require 'noosfero/transliterations'

class String
  def to_slug
    transliterate.downcase.gsub( /[^-a-z0-9~\s\.:;+=_]/, '').gsub(/[\s:;=_+]+/, '-').gsub(/[\-]{2,}/, '-').to_s
  end
end
