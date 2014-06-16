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

  def suggestion_based_on_username(requested_username='')
    return "" if requested_username.empty?

    requested_username = requested_username.downcase.tr("^#{Profile::IDENTIFIER_FORMAT}", '')
    usernames = []
    tries = 0
    3.times do
      begin
        valid_name = requested_username + rand(1000).to_s
        tries += 1
        invalid = usernames.include?(valid_name) || !Person.is_available?(valid_name, environment)
      end while tries <= 10 && invalid
      usernames << valid_name unless invalid
    end
    usernames
  end

end
