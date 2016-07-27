class OauthProviderPluginPublicController < PublicController

  before_action :doorkeeper_authorize!

  def me
    user = environment.users.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    render :json => {:id =>user.login, :email => user.email}.to_json
  end

end
