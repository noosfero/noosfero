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

  def editable?(user=nil)
    false
  end

  def cacheable?
    false
  end
end
