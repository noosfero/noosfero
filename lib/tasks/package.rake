require 'noosfero'

desc "Generate source tarball"
task :package => 'package:clobber' do
  begin
    sh 'test -d .git'
  rescue
    puts "** The `package` task only works from within #{Noosfero::PROJECT}'s git repository."
    fail
  end
  begin
    sh 'test -f vendor/plugins/acts_as_solr/solr/start.jar'
  rescue
    puts "** The `package` task needs Solr installed within #{Noosfero::PROJECT}. Run 'rake solr:download'."
    fail
  end
  release = "#{Noosfero::PROJECT}-#{Noosfero::VERSION}"
  target = "pkg/#{release}"
  mkdir_p target
  sh "git archive HEAD | (cd #{target} && tar x)"

  #solr inclusion
  cp_r "vendor/plugins/acts_as_solr/solr", "#{target}/vendor/plugins/acts_as_solr", :verbose => true
  rm_r "#{target}/vendor/plugins/acts_as_solr/solr/work"
  mkdir_p "#{target}/vendor/plugins/acts_as_solr/solr/work"

  sh "cd pkg && tar czf #{release}.tar.gz #{release}"
end

task :clobber => 'package:clobber'
task 'package:clobber' do
  rm_rf 'pkg'
end
