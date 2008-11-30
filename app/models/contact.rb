class Contact < Task

  validates_presence_of :target_id, :subject, :email, :message
  validates_format_of :email, :with => Noosfero::Constants::EMAIL_FORMAT

  acts_as_having_settings :field => :data
  settings_items :subject, :message, :city_and_state, :email, :phone

  def description
    _('%s sent a new message') % (requestor ? requestor.name : _('Someone'))
  end

end
