# You should also enable delivery, shopping_cart and orders plugins.
system 'script/noosfero-plugins -q enable products'
unless(system 'gem list -i charlock_holmes')
  system 'gem install charlock_holmes'
end

