languages = Dir.glob('po/*').reject { |f| f =~ /pot$/ }.map { |f| File.basename(f) }

core_files = `grep '#:' po/noosfero.pot | cut -d ':' -f 2 | sed 's/^\s*//' | grep -v '^plugins' | sort -u`.split.map { |f| [ '-N', f] }.flatten

languages.each do |lang|

  lang_plugins_po = "tmp/#{lang}_plugins.po"
  system('msggrep', '-v', *core_files, '--output-file', lang_plugins_po, "po/#{lang}/noosfero.po")

  Dir.glob('plugins/*').each do |plugindir|
    plugin = File.basename(plugindir)
    po = File.join(plugindir, 'po', lang, plugin + '.po')

    files = []
    Dir.glob("#{plugindir}/**/*.{rb,html.erb}").each do |f|
      files << '-N' << f
    end

    system('mkdir', '-p', File.dirname(po))
    system('msggrep', *files, '--output-file', po, lang_plugins_po)

    if system("msgfmt --statistics -o /dev/null #{po} 2>&1 | grep -q '^0 translated message'")
      # empty .po
      system('rm', '-f', po)
      puts "[#{lang}] #{plugin}: PO file empty, deleted"
    else
      puts "[#{lang}] #{plugin}"
    end

  end

  system('rm', '-f', lang_plugins_po)
  system('find plugins/*/po -type d -empty -delete')
end
