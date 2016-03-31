if ENV['CI']
  system 'script/noosfero-plugins -q enable products'
  exit $?.exitstatus
end

