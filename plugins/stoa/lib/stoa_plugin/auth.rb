require 'sinatra'
require 'stoa_plugin/person_fields'

class StoaPlugin::Auth < Sinatra::Base

  include StoaPlugin::PersonFields

  post '/' do
    headers['Content-Type'] = 'application/json'
    if params[:login].blank?
      person = Person.find_by usp_id: params[:usp_id]
      login = person ? person.user.login : nil
    else
      login = params[:login]
    end

    domain = Domain.by_name(request.host)
    environment = domain && domain.environment
    environment ||= Environment.default

    user = User.authenticate(login, params[:password], environment)
    if user
      result = StoaPlugin::PersonApi.new(user.person, self).fields(selected_fields(params[:fields], user))
      result.merge!(:ok => true)
    else
      result = { :error => _('Incorrect user/password pair.'), :ok => false }
    end
    result.to_json
  end

  get '/' do
    headers['Content-Type'] = 'application/json'
    { :error => _('Conection requires post method.'), :ok => false }.to_json
  end

end
