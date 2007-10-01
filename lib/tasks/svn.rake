require 'noosfero'

namespace 'svn' do
  task 'tag' do
    sh "svn copy #{Noosfero::SVN_ROOT}/trunk #{Noosfero::SVN_ROOT}/tags/#{Noosfero::VERSION}"
    puts "*************************************************************"
    puts "** please remember to change the version in lib/noosfero.rb !"
    puts "*************************************************************"
  end
end
