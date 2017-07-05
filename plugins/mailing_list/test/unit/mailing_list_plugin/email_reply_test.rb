require 'test_helper'

class MailingListPlugin::EmailReplyTest < ActiveSupport::TestCase

  FIXTURES_PATH = File.dirname(__FILE__) + '/../../fixtures'

  should 'not queue job with empty message' do
    Delayed::Job.expects(:enqueue).never
    MailingListPlugin::EmailReply.new(File.read(File.join(FIXTURES_PATH, 'sample-emails', 'empty-message.txt')))
  end

  should 'not queue job with empty uuid' do
    Delayed::Job.expects(:enqueue).never
    MailingListPlugin::EmailReply.new(File.read(File.join(FIXTURES_PATH, 'sample-emails', 'empty-uuid.txt')))
  end

  should 'queue job with proper reply' do
    Delayed::Job.expects(:enqueue).once
    MailingListPlugin::ProcessReplyJob.expects(:new).with('sample@example.org', '06cd4d14-ad34-47e5-a774-d359816de348', "Hello world?\n")
    MailingListPlugin::EmailReply.new(File.read(File.join(FIXTURES_PATH, 'sample-emails', 'valid-reply.txt')))
  end

  should 'extract text plain from multipart email' do
    Delayed::Job.expects(:enqueue).once
    MailingListPlugin::ProcessReplyJob.expects(:new).with('sample@example.org', '06cd4d14-ad34-47e5-a774-d359816de348', "Hello world?\n")
    MailingListPlugin::EmailReply.new(File.read(File.join(FIXTURES_PATH, 'sample-emails', 'multipart-valid-reply.txt')))
  end
end
