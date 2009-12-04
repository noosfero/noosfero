#
# Added for Ruby-GetText-Package
#

require 'noosfero'

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
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

  GetText.update_pofiles(Noosfero::PROJECT, Dir.glob("{app,lib}/**/*.{rb,rhtml}") + Dir.glob('public/*.html.erb'),
                         "#{Noosfero::PROJECT} #{Noosfero::VERSION}")
end

# vim: ft=ruby
