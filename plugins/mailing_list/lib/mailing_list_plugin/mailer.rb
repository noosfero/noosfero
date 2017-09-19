class MailingListPlugin::Mailer < ApplicationMailer
  def reply_email(content)
    @content = content
    @body = parse_relative_references(content)
    environment_settings = Noosfero::Plugin::Settings.new content.environment, MailingListPlugin
    client = MailingListPlugin::Client.new(environment_settings)

    to = client.group_list_email(content.profile)
    from = "#{content.author_name} <#{environment_settings.administrator_email}>"

    headers['Message-ID'] = generate_uuid(content)
    if content.kind_of?(Comment)
      reference = content.reply_of || content.source
      headers['In-Reply-To'] = generate_uuid(reference)
    end

    mail(to: to, from: from, subject: generate_subject(content)) do |format|
      format.html
      format.text
    end
  end

  private

  def generate_uuid(content)
    settings = Noosfero::Plugin::Metadata.new content, MailingListPlugin
    "<#{settings.uuid}>"
  end

  def generate_subject(content)
    prefix = ''
    if content.kind_of?(Comment)
      source = content.source
      prefix += _("Re:") + ' '
    else
      source = content
    end

    "#{prefix}[#{source.parent.title}] #{source.title}"
  end

  def parse_relative_references(content)
    doc = Nokogiri::HTML::DocumentFragment.parse(content.to_html)
    elements_map = {img: 'src', a: 'href', audio: 'src', embed: 'src', iframe: 'src', source: 'src', video: 'src'}
    top_url = content.profile.top_url

    elements_map.each do |selector, attribute|
      doc.css(selector.to_s).each do |element|
        element[attribute] = URI.join(top_url, element[attribute]).to_s
      end
    end

    doc.to_html
  end
end
