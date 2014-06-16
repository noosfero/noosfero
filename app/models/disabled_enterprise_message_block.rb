class DisabledEnterpriseMessageBlock < Block

  def self.description
    _('"Disabled enterprise" message')
  end

  def help
    _('Shows a message for disabled enterprises.')
  end

  def default_title
    _('Message')
  end

  def content(args={})
    message = self.owner.environment.message_for_disabled_enterprise || ''
    lambda do |_|
       render :file => 'blocks/disabled_enterprise_message', :locals => {:message => message}
    end
  end

  def editable?
    false
  end

  def cacheable?
    false
  end
end
