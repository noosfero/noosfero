module Noosfero
  PROJECT = 'noosfero'
  VERSION = '1.4'
end

root = File.expand_path(File.dirname(__FILE__) + '/../..')
if File.exist?(File.join(root, '.git')) && system('which git >/dev/null')
  git_version = Dir.chdir(root) { `git describe --tags 2>/dev/null`.to_s.strip.sub('-rc', '~rc') }
  if git_version != ''
    version_sort = IO.popen(['sort', '--version-sort'], 'w+')
    version_sort.puts(Noosfero::VERSION)
    version_sort.puts(git_version)
    version_sort.close_write
    new_version = version_sort.readlines.last.strip
    if new_version != Noosfero::VERSION
      Noosfero::VERSION.clear << git_version
    end
    version_sort.close
  end
end
