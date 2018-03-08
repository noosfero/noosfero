system 'script/noosfero-plugins -q enable products delivery shopping_cart orders'
unless(system 'gem list -i charlock_holmes')
  system 'gem install charlock_holmes'
end

