require 'test_helper'

class MailingListPlugin::DeployAllJobTest < ActiveSupport::TestCase
  def setup
    @client = mock
    MailingListPlugin::Client.stubs(:new).returns(@client)
  end

  attr_accessor :client

  should 'create a comment on an article if uuid belongs to article' do
    environment = Environment.default
    environment_settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
    environment_settings.deploying_communities = true
    environment_settings.save!
    c1 = fast_create(Community)
    c2 = fast_create(Community)
    c3 = fast_create(Community, :is_template => true)

    client.expects(:deploy_list_for_group).with(c1).once
    client.expects(:deploy_list_for_group).with(c2).once
    client.expects(:deploy_list_for_group).with(c3).never

    job = MailingListPlugin::DeployAllJob.new(environment.id, :communities)
    job.perform

    environment.reload
    environment_settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
    refute environment_settings.deploying_communities
  end
end
