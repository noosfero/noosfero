# You should also enable products and suppliers plugins.
system "script/noosfero-plugins -q enable delivery orders"
exit $?.exitstatus

