system 'script/noosfero-plugins -q enable products delivery shopping_cart suppliers'
unless(system 'gem list -i axlsx')
  system 'gem install axlsx'
end
