# encoding: utf-8

class String

  TRANSLITERATIONS = {
    [ 'Á', 'À', 'À', 'Â', 'Ã', 'Ä', 'Å' ] => 'A',
    [ 'á', 'à', 'à', 'â', 'ã', 'ä', 'å' ,'ª' ] => 'a',
    [ 'É', 'È', 'Ê', 'Ë' ] => 'E',
    [ 'é', 'è', 'ê', 'ë' ] => 'e',
    [ 'Í', 'Ì', 'Î', 'Ï' ] => 'I',
    [ 'í', 'ì', 'î', 'ï' ] => 'i',
    [ 'Ó', 'Ò', 'Ô', 'Ö', 'Õ', 'º' ] => 'O',
    [ 'ó', 'ò', 'ô', 'ö', 'õ', 'º' ] => 'o',
    [ 'Ú', 'Ù', 'Û', 'Ü' ] => 'U',
    [ 'ú', 'ù', 'û', 'ü' ] => 'u',
    [ 'ß' ] => 'ss',
    [ 'Ç' ] => 'C',
    [ 'ç' ] => 'c',
    [ 'Ñ' ] => 'N',
    [ 'ñ' ] => 'n',
    [ 'Ÿ' ] => 'Y',
    [ 'ÿ' ] => 'y',
# Cyrillic alphabet transliteration
    [ 'а', 'А' ] => 'a',
    [ 'б', 'Б' ] => 'b',
    [ 'в', 'В' ] => 'v',
    [ 'г', 'Г' ] => 'g',
    [ 'д', 'Д' ] => 'd',
    [ 'е', 'Е' ] => 'e',
    [ 'ё', 'Ё' ] => 'yo',
    [ 'ж', 'Ж' ] => 'zh',
    [ 'з', 'З' ] => 'z',
    [ 'и', 'И' ] => 'i',
    [ 'й', 'Й' ] => 'y',
    [ 'к', 'К' ] => 'k',
    [ 'л', 'Л' ] => 'l',
    [ 'м', 'М' ] => 'm',
    [ 'н', 'Н' ] => 'n',
    [ 'о', 'О' ] => 'o',
    [ 'п', 'П' ] => 'p',
    [ 'р', 'Р' ] => 'r',
    [ 'с', 'С' ] => 's',
    [ 'т', 'Т' ] => 't',
    [ 'у', 'У' ] => 'u',
    [ 'ф', 'Ф' ] => 'f',
    [ 'х', 'Х' ] => 'h',
    [ 'ц', 'Ц' ] => 'ts',
    [ 'ч', 'Ч' ] => 'ch',
    [ 'ш', 'Ш' ] => 'sh',
    [ 'щ', 'Щ' ] => 'sch',
    [ 'э', 'Э' ] => 'e',
    [ 'ю', 'Ю' ] => 'yu',
    [ 'я', 'Я' ] => 'ya',
    [ 'ы', 'Ы' ] => 'i',
    [ 'ь', 'Ь' ] => '',
    [ 'ъ', 'Ъ' ] => '',
# Ukrainian lovely letters
    [ 'і', 'І' ] => 'i',
    [ 'ї', 'Ї' ] => 'yi',
    [ 'є', 'Є' ] => 'ye',
    [ 'ґ', 'Ґ' ] => 'g',
  }

  # transliterate a string (assumed to contain UTF-8 data)
  # into ASCII by replacing non-ascii characters to their
  # ASCII.
  #
  # The transliteration is, of course, lossy, and its performance is poor.
  # Don't abuse this method.
  def transliterate

    new = self.dup
    TRANSLITERATIONS.each { |from,to|
      from.each { |seq|
        new.gsub!(seq, to)
      }
    }
    new
  end

  def to_slug
    transliterate.downcase.gsub(/[^[[:word:]]~\s:;+=_."'`-]/, '').gsub(/[\s:;+=_"'`-]+/, '-').gsub(/-$/, '').gsub(/^-/, '').to_s
  end

  def to_css_class
    underscore.dasherize.gsub('/','_')
  end

  def fix_i18n
    self.sub('{fn} ', '')
  end

end
