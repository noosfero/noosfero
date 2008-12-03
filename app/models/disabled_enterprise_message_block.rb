class DisabledEnterpriseMessageBlock < Block

  def self.description
    _('Disabled enterprise message block')
  end

  def help
    _('Shows a message for disabled enterprises.')
  end

  def default_title
    _('Message')
  end

  def content
    message = self.owner.environment.message_for_disabled_enterprise || ''
    content_tag('div', message, :class => 'enterprise-disabled')
  end

  def editable?
    false
  end
end
