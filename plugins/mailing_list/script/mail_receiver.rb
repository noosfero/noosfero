#!/usr/bin/env ruby

require_relative '../../../lib/standalone_delayed_job'

module MailingListPlugin; end
require_relative '../lib/mailing_list_plugin/email_reply'
require_relative '../lib/mailing_list_plugin/process_reply_job'

MailingListPlugin::EmailReply.new($stdin.read)
