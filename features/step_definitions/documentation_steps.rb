require File.join(Rails.root, 'test', 'support', 'noosfero_doc_test')
include Noosfero::DocTest

Given 'the documentation is built' do
  setup_doc_test
end

After('@docs') do
  tear_down_doc_test
end
