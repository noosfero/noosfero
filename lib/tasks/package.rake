require 'noosfero'

desc "Generate source tarball"
task :package => 'package:clobber' do
  begin
    sh 'test -d .git'
  rescue
    puts "** The `package` task only works from within #{Noosfero::PROJECT}'s git repository."
    fail
  end
  release = "#{Noosfero::PROJECT}-#{Noosfero::VERSION}"
  target = "pkg/#{release}"
  mkdir_p target
  sh "git archive HEAD | (cd #{target} && tar x)"
  sh "cd pkg && tar czf #{release}.tar.gz #{release}"
end

task :clobber => 'package:clobber'
task 'package:clobber' do
  rm_rf 'pkg'
end
