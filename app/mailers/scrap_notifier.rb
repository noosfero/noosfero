class ScrapNotifier < ActionMailer::Base
  def notification(scrap)
    sender, receiver = scrap.sender, scrap.receiver
    # for tests
    return unless receiver.email

    @recipient = receiver.name
    @sender = sender.name
    @sender_link = sender.url
    @scrap_content = scrap.content
    @wall_url = scrap.scrap_wall_url
    @environment = sender.environment.name
    @url = sender.environment.top_url
    mail(
      to: receiver.email,
      from: "#{sender.environment.name} <#{sender.environment.noreply_email}>",
      subject: _("[%s] You received a scrap!") % [sender.environment.name]
    )
  end
end
