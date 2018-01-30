system "script/noosfero-plugins -q enable oauth_client open_graph products"

system 'gem install fb_graph'
system 'gem install fb_graph2'
system 'gem install facebook-signed-request'

exit $?.exitstatus

