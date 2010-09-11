#
# Added for Ruby-GetText-Package
#

require 'noosfero'

makemo_stamp = 'tmp/makemo.stamp'
desc "Create mo-files for L10n"
task :makemo => makemo_stamp
file makemo_stamp => Dir.glob('po/*/noosfero.po') do
  ruby '-rconfig/boot -rgettext -rgettext/utils -e \'GetText.create_mofiles(true, "po", "locale")\' 2>/dev/null'
  FileUtils.touch makemo_stamp
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext'
  require 'gettext/rails'
  require 'gettext/utils'
  GetText::RubyParser::ID << '__'
  GetText::RubyParser::PLURAL_ID << 'n__'
  GetText::ActiveRecordParser.init(:use_classname => false)

  module GetText
    module_function
    def update_pofiles(textdomain, files, app_version, po_root = "po", refpot = "tmp.pot")
      rgettext(files, refpot)
      system("mv tmp.pot tmp2.pot; msguniq -o tmp.pot tmp2.pot; rm -f tmp2.pot")
      msgmerge_all(textdomain, app_version, po_root, refpot)
      File.delete(refpot)
    end
  end

  sources =
    Dir.glob("{app,lib}/**/*.{rb,rhtml,erb}") +
    Dir.blog('config/initializers/*.rb')
    Dir.glob('public/*.html.erb') +
    Dir.glob('public/designs/themes/{base,noosfero}/*.{rhtml,html.erb}')
  GetText.update_pofiles(Noosfero::PROJECT, sources, "#{Noosfero::PROJECT} #{Noosfero::VERSION}")
end

# vim: ft=ruby
