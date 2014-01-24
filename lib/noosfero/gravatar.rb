module Noosfero::Gravatar
  def gravatar_profile_image_url(email, options = {})
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.to_s)}?" + {
      :only_path => false,
    }.merge(options).map{|k,v| '%s=%s' % [ k,v ] }.join('&')
  end

  def gravatar_profile_url(email)
    'http://www.gravatar.com/'+ Digest::MD5.hexdigest(email.to_s)
  end
end
