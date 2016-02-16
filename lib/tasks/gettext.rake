#
# Added for Ruby-GetText-Package
#

require 'pathname'

require 'gettext/tools/task'
GetText::Tools::Task.define do |task|
  task.domain = 'noosfero'
  task.enable_po = true
  task.po_base_directory = 'po'
  task.mo_base_directory = 'locale'
  task.files = [
    "{app,lib}/**/*.{rb,rhtml,erb}",
    'config/initializers/*.rb',
    'public/*.html.erb',
    'public/designs/themes/{base,noosfero,profile-base}/*.{rhtml,html.erb}',
  ].map { |pattern| Dir.glob(pattern) }.flatten

  # installed, no po/ available
  if !File.directory?(task.po_base_directory)
    task.locales = Dir.chdir(task.mo_base_directory) { Dir.glob('*') }
  end
end

task 'gettext:mo:update' => :symlinkmo
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

Dir.glob('plugins/*').each do |plugindir|
  plugin = File.basename(plugindir)
  po_root = File.join(plugindir, 'po')
  next if Dir["#{po_root}/**/*.po"].empty?

  namespace "noosfero:plugin:#{plugin}" do
    GetText::Tools::Task.define do |task|
      task.domain = plugin
      task.enable_po = true
      task.po_base_directory = po_root
      task.mo_base_directory = File.join(plugindir, 'locale')
      task.files = Dir["#{plugindir}/**/*.{rb,html.erb}"]
    end

    task "gettext:po:cleanup" do
      plugin_pot = File.join(po_root, plugin + '.pot')
      if File.exists?(plugin_pot) && system("LANG=C msgfmt --statistics --output /dev/null #{plugin_pot} 2>&1 | grep -q '^0 translated messages.$'")
        rm_f plugin_pot
      end
      sh 'find', po_root, '-type', 'd', '-empty', '-delete'
    end

    task "gettext:po:update" do
      Rake::Task["noosfero:plugin:#{plugin}:gettext:po:cleanup"].invoke
    end
    task "gettext:mo:update" do
      Rake::Task["noosfero:plugin:#{plugin}:gettext:po:cleanup"].invoke
    end
  end

  task 'gettext:po:update' => "noosfero:plugin:#{plugin}:gettext:po:update"
  task 'gettext:mo:update' => "noosfero:plugin:#{plugin}:gettext:mo:update"
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

task :makemo => 'tmp/makemo.stamp'
file 'tmp/makemo.stamp' do |t|
  sh 'find po plugins/*/po -name "*.po" -exec touch "{}" ";"'
  Rake::Task['gettext:mo:update'].invoke
  touch t.name
end

task :updatepo => 'gettext:po:update' do
  Dir.glob('{po,plugins}/**/*.po').each do |po|
    sh "cp #{po} #{po}.tmp && msguniq -o #{po} #{po}.tmp && rm -f #{po}.tmp"
  end
end

# vim: ft=ruby
