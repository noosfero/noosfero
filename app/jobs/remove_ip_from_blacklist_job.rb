class RemoveIpFromBlacklistJob < Struct.new(:environment_id, :ip_address)
  def perform
    environment = Environment.find(environment_id)
    environment.remove_from_signup_blacklist(ip_address)
  end
end
