class MailingJob < Struct.new(:mailing_id)
  def perform
    mailing = Mailing.find(mailing_id)
    Noosfero.with_locale(mailing.locale) do
      mailing.deliver
    end
  end
end
