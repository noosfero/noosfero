require 'project_meta'

namespace 'svn' do
  task 'tag' do
    sh "svn copy #{Noosfero::SVN_ROOT}/trunk #{Noosfero::SVN_ROOT}/tags/#{Noosfero::VERSION}"
  end
end
