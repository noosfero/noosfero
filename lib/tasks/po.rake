def extract_po_stat(name, text)
  if text =~ /(\d+) #{name}/
    return $1.to_i
  else
    return 0
  end
end

namespace :po do

  task :stats do
    require 'term/ansicolor'
    class PoOutput
      include Term::ANSIColor
      def ok(text)
        print green, text, clear, "\n"
      end
      def not_ok(text)
        print red, text, clear, "\n"
      end
    end
    out = PoOutput.new

    ENV['LANG'] = 'C'
    puts "+----------+----------+------------+--------+--------------+"
    puts "| Language | Messages | Translated |  Fuzzy | Untranslated |"
    puts "+----------+----------+------------+--------+--------------+"
    Dir.glob(Rails.root.join('po', '*', 'noosfero.po')).each do |file|
      language = File.basename(File.dirname(file))
      output = `msgfmt --output /dev/null --statistics #{file} 2>&1`
      translated   = extract_po_stat('translated', output)
      fuzzy        = extract_po_stat('fuzzy', output)
      untranslated = extract_po_stat('untranslated', output)
      total        = translated + fuzzy + untranslated

      line = "| %-8s | %8d | %10d | %6d | %12d |" % [language, total, translated, fuzzy, untranslated]
      if total == translated
        out.ok(line)
      else
        out.not_ok(line)
      end
    end
    puts "+----------+----------+------------+--------+--------------+"
  end

end
