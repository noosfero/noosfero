module Noosfero
  PROJECT = 'noosfero'
  VERSION = '1.3'
end

root = File.expand_path(File.dirname(__FILE__) + '/../..')
if File.exist?(File.join(root, '.git')) && system('which git >/dev/null')
  git_version = Dir.chdir(root) { `git describe --tags`.to_s.strip.sub('-rc', '~rc') }
  if git_version > Noosfero::VERSION
    Noosfero::VERSION.clear << git_version
  end
end
