# can't be done in install.rb as this is a baseplugin
if ENV['CI']
  system 'script/noosfero-plugins -q enable products'
end

require 'test_helper'
