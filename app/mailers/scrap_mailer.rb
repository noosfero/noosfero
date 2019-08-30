class ScrapMailer < ApplicationMailer
  def new_scrap(scrap)
    sender, receiver = scrap.sender, scrap.receiver
    self.environment = sender.environment
    # for tests
    return unless receiver.email

    @recipient = receiver.name
    @sender = sender.name
    @sender_link = sender.url
    @scrap_content = scrap.content
    @wall_url = scrap.scrap_wall_url
    @url = sender.environment.top_url
    mail(
      to: receiver.email,
      from: "#{sender.environment.name} <#{sender.environment.noreply_email}>".html_safe,
      subject: _("[%s] You received a scrap!").html_safe % [sender.environment.name]
    )
  end
end
