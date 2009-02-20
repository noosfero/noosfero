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
    [ 'Ç' ] => 'C',
    [ 'ç' ] => 'c',
    [ 'Ñ' ] => 'N',
    [ 'ñ' ] => 'n',
    [ 'Ÿ' ] => 'Y',
    [ 'ÿ' ] => 'y',
  }

  # transliterate a string (assumed to contain UTF-8 data)
  # into ASCII by replacing non-ascii characters to their
  # ASCII.
  #
  # The transliteration is, of course, lossy, and its performance is poor.
  # Don't abuse this method.
  def transliterate

    new = self.clone
    TRANSLITERATIONS.each { |from,to|
      from.each { |seq|
        new.gsub!(seq, to)
      }
    }
    new
  end

  def to_slug
    transliterate.downcase.gsub(/^\d+/,'').gsub( /[^a-z0-9~\s:;+=_."'`-]/, '').gsub(/[\s:;+=_"'`-]+/, '-').gsub(/-$/, '').gsub(/^-/, '').to_s
  end

end
