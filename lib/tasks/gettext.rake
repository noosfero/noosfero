#
# Added for Ruby-GetText-Package
#

require 'noosfero'

makemo_stamp = 'tmp/makemo.stamp'
desc "Create mo-files for L10n"
task :makemo => makemo_stamp
file makemo_stamp => Dir.glob('po/*/noosfero.po') do
  ruby '-rconfig/boot -rgettext -rgettext/utils -e \'GetText.create_mofiles(true, "po", "locale")\' 2>/dev/null'
  Rake::Task['symlinkmo'].invoke
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
  mkdir_p(File.join(Rails.root, 'locale'))
  Dir.glob(File.join(Rails.root, 'locale/*')).each do |dir|
    lang = File.basename(dir)
    orig_lang = langmap[lang] || lang
    mkdir_p("#{Rails.root}/locale/#{lang}/LC_MESSAGES")
    ['iso_3166', 'rails'].each do |domain|
      origin = "/usr/share/locale/#{orig_lang}/LC_MESSAGES/#{domain}.mo"
      target = "#{Rails.root}/locale/#{lang}/LC_MESSAGES/#{domain}.mo"
      if !File.symlink?(target)
        ln_s origin, target
      end
    end
  end
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext_rails/tools'
  GetText::RubyParser::ID << '__'
  GetText::RubyParser::PLURAL_ID << 'n__'
  GetText::ActiveRecordParser.init(:use_classname => false)

  puts 'Extracting strings from source. This may take a while ...'
  sources =
    Dir.glob("{app,lib}/**/*.{rb,rhtml,erb}") +
    Dir.glob("plugins/**/*.{rb,rhtml,erb}") +
    Dir.glob('config/initializers/*.rb') +
    Dir.glob('public/*.html.erb') +
    Dir.glob('public/designs/themes/{base,noosfero,profile-base}/*.{rhtml,html.erb}') +
    Dir.glob('plugins/**/{controllers,lib,views}/**/*.{rhtml,html.erb,rb}')
  GetText.update_pofiles(Noosfero::PROJECT, sources, "#{Noosfero::PROJECT} #{Noosfero::VERSION}")
end

task :checkpo do
  sh 'for po in po/*/noosfero.po; do echo -n "$po: "; msgfmt --statistics --output /dev/null $po; done'
end

# vim: ft=ruby
