#
# Added for Ruby-GetText-Package
#

require 'pathname'

makemo_stamp = 'tmp/makemo.stamp'
desc "Create mo-files for L10n"
task :makemo => makemo_stamp
file makemo_stamp => Dir.glob('po/*/noosfero.po') do
  Rake::Task['symlinkmo'].invoke

  require 'gettext'
  require 'gettext/tools'
  GetText.create_mofiles(
    verbose: true,
    po_root: 'po',
    mo_root: 'locale',
  )

  Dir.glob('plugins/*').each do |plugindir|
    GetText.create_mofiles(
      verbose: true,
      po_root: File.join(plugindir, 'po'),
      mo_root: File.join(plugindir, 'locale'),
    )
  end

  FileUtils.mkdir_p 'tmp'
  FileUtils.touch makemo_stamp
end

task :cleanmo do
  rm_f makemo_stamp
end
task :clean => 'cleanmo'

task :symlinkmo do
  langmap = {
    'pt' => 'pt_BR',
  }
  root = Pathname.new(File.dirname(__FILE__) + '/../..').expand_path
  mkdir_p(root.join('locale'))
  Dir.glob(root.join('po/*/')).each do |dir|
    lang = File.basename(dir)
    orig_lang = langmap[lang] || lang
    mkdir_p(root.join('locale', "#{lang}", 'LC_MESSAGES'))
    ['iso_3166'].each do |domain|
      origin = "/usr/share/locale/#{orig_lang}/LC_MESSAGES/#{domain}.mo"
      target = root.join('locale', "#{lang}", 'LC_MESSAGES', "#{domain}.mo")
      if !File.symlink?(target)
        ln_s origin, target
      end
    end
  end
end

desc "Update pot/po files to match new version."
task :updatepo do

  puts 'Extracting strings from source. This may take a while ...'

  files_to_translate = [
    "{app,lib}/**/*.{rb,rhtml,erb}",
    'config/initializers/*.rb',
    'public/*.html.erb',
    'public/designs/themes/{base,noosfero,profile-base}/*.{rhtml,html.erb}',
  ].map { |pattern| Dir.glob(pattern) }.flatten

  require 'gettext'
  require 'gettext/tools'
  GetText.update_pofiles(
    'noosfero',
    files_to_translate,
    Noosfero::VERSION,
    {
      po_root: 'po',
    }
  )
end

Dir.glob('plugins/*').each do |plugindir|
  plugin = File.basename(plugindir)
  task :updatepo => "updatepo:plugin:#{plugin}"

  desc "Extract strings from #{plugin} plugin"
  task "updatepo:plugin:#{plugin}" do
    files = Dir.glob("#{plugindir}/**/*.{rb,html.erb}")
    po_root = File.join(plugindir, 'po')
    require 'gettext'
    require 'gettext/tools'
    GetText.update_pofiles(
      plugin,
      files,
      Noosfero::VERSION,
      {
        po_root: po_root,
      }
    )
    plugin_pot = File.join(po_root, "#{plugin}.pot")
    if File.exists?(plugin_pot) && system("LANG=C msgfmt --statistics --output /dev/null #{plugin_pot} 2>&1 | grep -q '^0 translated messages.$'")
      rm_f plugin_pot
    end
    sh 'find', po_root, '-type', 'd', '-empty', '-delete'
    puts
  end
end

def checkpo(po_files)
  max = po_files.map(&:size).max
  po_files.each do |po|
    printf "%#{max}s: ", po
    system "msgfmt --statistics --output /dev/null " + po
  end
end

desc "checks core translation files"
task :checkpo do
  checkpo(Dir.glob('po/*/noosfero.po'))
end

languages = Dir.glob('po/*').select { |d| File.directory?(d) }.map { |d| File.basename(d) }
languages.each do |lang|
  desc "checks #{lang} translation files"
  task "checkpo:#{lang}" do
    checkpo(Dir.glob("po/#{lang}/*.po") + Dir.glob("plugins/*/po/#{lang}/*.po"))
  end
end

# vim: ft=ruby
