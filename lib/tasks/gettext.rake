#
# Added for Ruby-GetText-Package
#

require 'gettext/utils'
require 'project_meta'

desc "Create mo-files for L10n"
task :makemo do
  GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
  GetText.update_pofiles(PROJECT, Dir.glob("{app,lib}/**/*.{rb,rhtml}"),
                         "#{PROJECT} #{VERSION}")
end

# vim: ft=ruby
