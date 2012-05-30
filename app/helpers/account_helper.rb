module AccountHelper

  def validation_classes
    'available unavailable valid validated invalid checking'
  end

  def checking_message(key)
    case key
    when :url
      _('Checking availability of login name...')
    when :email
      _('Checking if e-mail address is already taken...')
    end
  end
end
