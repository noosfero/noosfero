class DisabledEnterpriseMessageBlock < Block

  def self.description
    __('"Disabled enterprise" message')
  end

  def help
    __('Shows a message for disabled enterprises.')
  end

  def default_title
    _('Message')
  end

  def content
    message = self.owner.environment.message_for_disabled_enterprise || ''
    lambda do
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
