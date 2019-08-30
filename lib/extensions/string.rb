# encoding: utf-8

class String
  TRANSLITERATIONS = {
    ["\u00C1", "\u00C0", "\u00C0", "\u00C2", "\u00C3", "\u00C4", "\u00C5"] => "A",
    ["\u00E1", "\u00E0", "\u00E0", "\u00E2", "\u00E3", "\u00E4", "\u00E5", "\u00AA"] => "a",
    ["\u00C9", "\u00C8", "\u00CA", "\u00CB"] => "E",
    ["\u00E9", "\u00E8", "\u00EA", "\u00EB"] => "e",
    ["\u00CD", "\u00CC", "\u00CE", "\u00CF"] => "I",
    ["\u00ED", "\u00EC", "\u00EE", "\u00EF"] => "i",
    ["\u00D3", "\u00D2", "\u00D4", "\u00D6", "\u00D5", "\u00BA"] => "O",
    ["\u00F3", "\u00F2", "\u00F4", "\u00F6", "\u00F5", "\u00BA"] => "o",
    ["\u00DA", "\u00D9", "\u00DB", "\u00DC"] => "U",
    ["\u00FA", "\u00F9", "\u00FB", "\u00FC"] => "u",
    ["\u00DF"] => "ss",
    ["\u00C7"] => "C",
    ["\u00E7"] => "c",
    ["\u00D1"] => "N",
    ["\u00F1"] => "n",
    ["\u0178"] => "Y",
    ["\u00FF"] => "y",
    # Cyrillic alphabet transliteration
    ["\u0430", "\u0410"] => "a",
    ["\u0431", "\u0411"] => "b",
    ["\u0432", "\u0412"] => "v",
    ["\u0433", "\u0413"] => "g",
    ["\u0434", "\u0414"] => "d",
    ["\u0435", "\u0415"] => "e",
    ["\u0451", "\u0401"] => "yo",
    ["\u0436", "\u0416"] => "zh",
    ["\u0437", "\u0417"] => "z",
    ["\u0438", "\u0418"] => "i",
    ["\u0439", "\u0419"] => "y",
    ["\u043A", "\u041A"] => "k",
    ["\u043B", "\u041B"] => "l",
    ["\u043C", "\u041C"] => "m",
    ["\u043D", "\u041D"] => "n",
    ["\u043E", "\u041E"] => "o",
    ["\u043F", "\u041F"] => "p",
    ["\u0440", "\u0420"] => "r",
    ["\u0441", "\u0421"] => "s",
    ["\u0442", "\u0422"] => "t",
    ["\u0443", "\u0423"] => "u",
    ["\u0444", "\u0424"] => "f",
    ["\u0445", "\u0425"] => "h",
    ["\u0446", "\u0426"] => "ts",
    ["\u0447", "\u0427"] => "ch",
    ["\u0448", "\u0428"] => "sh",
    ["\u0449", "\u0429"] => "sch",
    ["\u044D", "\u042D"] => "e",
    ["\u044E", "\u042E"] => "yu",
    ["\u044F", "\u042F"] => "ya",
    ["\u044B", "\u042B"] => "i",
    ["\u044C", "\u042C"] => "",
    ["\u044A", "\u042A"] => "",
    # Ukrainian lovely letters
    ["\u0456", "\u0406"] => "i",
    ["\u0457", "\u0407"] => "yi",
    ["\u0454", "\u0404"] => "ye",
    ["\u0491", "\u0490"] => "g",
  }

  # transliterate a string (assumed to contain UTF-8 data)
  # into ASCII by replacing non-ascii characters to their
  # ASCII.
  #
  # The transliteration is, of course, lossy, and its performance is poor.
  # Don't abuse this method.
  def transliterate
    new = self.dup
    TRANSLITERATIONS.each { |from, to|
      from.each { |seq|
        new.gsub!(seq, to)
      }
    }
    new
  end

  def to_slug
    transliterate.downcase.gsub(/[^[[:word:]]~\s:;+=_."'`-]/, "").gsub(/[\s:;+=_"'`-]+/, "-").gsub(/-$/, "").gsub(/^-/, "").to_s
  end

  def to_css_class
    underscore.dasherize.gsub("/", "_")
  end

  def fix_i18n
    self.sub("{fn} ", "")
  end
end
