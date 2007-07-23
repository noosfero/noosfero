#
# Added for Ruby-GetText-Package
#

require 'gettext/utils'

desc "Create mo-files for L10n"
task :makemo do
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
  GetText.update_pofiles('anhetegua', Dir.glob("{app,lib}/**/*.{rb,rhtml}"),
                         "anhetegua 0.1.0")
end

# vim: ft=ruby
