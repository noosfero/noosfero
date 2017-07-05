#!/usr/bin/env ruby

# Test purposes only
f = File.open('/tmp/started', 'w')
f.write('bli')
f.close

require_relative '../../../lib/standalone_delayed_job'

module MailingListPlugin; end
require_relative '../lib/mailing_list_plugin/email_reply'
require_relative '../lib/mailing_list_plugin/process_reply_job'

MailingListPlugin::EmailReply.new($stdin.read)

# Test purposes only
f = File.open('/tmp/finished', 'w')
f.write('bli')
f.close
