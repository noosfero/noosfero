# You should also enable shopping_cart and orders plugins.
system 'script/noosfero-plugins -q enable products delivery'
unless(system 'gem list -i axlsx')
  system 'gem install axlsx'
end
