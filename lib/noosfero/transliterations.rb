module Noosfero::Transliterations

  TRANSLATION = {
    [ 'Á', 'À', 'À', 'Â', 'Ã', 'Ä' ] => 'A',
    [ 'á', 'à', 'à', 'â', 'ã', 'ä', 'ª' ] => 'a',
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

  # transliterate a string (assumed to be contain UTF-8 data)
  # into ASCII by replacing non-ascii characters to their
  # ASCII.
  #
  # The transliteration is, of course, lossy, and its performance is poor.
  def transliterate

    new = self.clone
    Noosfero::Transliterations::TRANSLATION.each { |from,to|
      from.each { |seq|
        new.gsub!(seq, to)
      }
    }
    new
  end
end

String.send(:include, Noosfero::Transliterations)
