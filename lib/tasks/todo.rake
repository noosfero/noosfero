desc "lists all TODO and FIXME comments in the source code"
task :todo do
  sh 'grep "TODO\|FIXME" -r --exclude "*.svn*" -n app lib vendor/plugins/ | sed -e "s/^[^:]\+:[0-9]\+:/=============================\n&\n/"'
end
