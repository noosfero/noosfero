#
# Added for Ruby-GetText-Package
#

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
  mkdir_p(Rails.root.join('locale'))
  Dir.glob(Rails.root.join('po/*/')).each do |dir|
    lang = File.basename(dir)
    orig_lang = langmap[lang] || lang
    mkdir_p(Rails.root.join('locale', "#{lang}", 'LC_MESSAGES'))
    ['iso_3166'].each do |domain|
      origin = "/usr/share/locale/#{orig_lang}/LC_MESSAGES/#{domain}.mo"
      target = Rails.root.join('locale', "#{lang}", 'LC_MESSAGES', "#{domain}.mo")
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
    'plugins/**/{controllers,models,lib,views}/**/*.{rhtml,html.erb,rb}',
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

task :checkpo do
  sh 'for po in po/*/noosfero.po; do echo -n "$po: "; msgfmt --statistics --output /dev/null $po; done'
end

# vim: ft=ruby
