class MailingListPlugin::DeployAllJob < Struct.new(:environment_id, :kind)
  def perform
    environment = Environment.find(environment_id)
    environment_settings = Noosfero::Plugin::Settings.new environment, MailingListPlugin
    client = MailingListPlugin::Client.new(environment_settings)

    environment.send(kind).no_templates.find_each do |group|
      begin
        client.deploy_list_for_group(group)
      rescue
        logger = Delayed::Worker.logger
        logger.error("== [MailingListPlugin] Could not deploy #{group.name}")
      end
    end

    environment_settings.send("deploying_#{kind}=", false)
    environment_settings.save!
  end
end
