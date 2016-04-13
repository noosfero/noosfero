require 'ostruct'

module ExternalUser
  extend ActiveSupport::Concern

  included do
    attr_accessor :external_person_id
  end

  def external_person
    ExternalPerson.where(id: self.external_person_id).first
  end

  def person_with_external
    self.external_person || self.person_without_external
  end

  module ClassMethods
    def webfinger_lookup(login, domain, environment)
      if login && domain && environment.has_federated_network?(domain)
        # Ask if network at <domain> has user with login <login>
        # FIXME: Make an actual request to the federated network, which should return nil if not found
        {
          login: login
        }
      else
        nil
      end
    end

    def build_request(uri)
      request = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"  # enable SSL/TLS
        request.use_ssl = true
        #TODO There may be self-signed certificates that we would not be able
        #to verify, so we'll not verify the ssl certificate for now. Since
        #this requests will go only towards trusted federated networks the admin
        #configured we consider this not to be a big deal. Nonetheless we may be
        #able in the future to require/provide the CA Files on the federation
        #process which would allow us to verify the certificate.
        request.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request
    end

    def external_login(login, password, domain)
      # Call Noosfero /api/login
      result = nil
      response = nil
      redirections_allowed = 3
      location = 'http://' + domain + '/api/v1/login'
      request_params = CGI.unescape({ login: login, password: password }.to_query)
      begin
        while redirections_allowed > 0 && (response.blank? || response.code == '301')
          uri = URI.parse(location)
          request = build_request(uri)
          response = request.post(uri.to_s, request_params)
          location = response.header['location']
          redirections_allowed -= 1
        end
        result = response.code.to_i / 100 === 2 ? JSON.parse(response.body) : nil
      rescue
        # Could not make request
      end
      result
    end

    # Authenticates a user from an external social network
    def external_authenticate(username, password, environment)
      login, domain = username.split('@')
      webfinger = User.webfinger_lookup(login, domain, environment)
      if webfinger
        user = User.external_login(login, password, domain)
        if user
          u = User.new
          u.email = user['user']['email']
          u.login = login
          # FIXME: Instead of the struct below, we should use the "webfinger" object returned by the webfinger_lookup method
          webfinger = OpenStruct.new(
                        identifier: user['user']['person']['identifier'],
                        name: user['user']['person']['name'],
                        created_at: user['user']['person']['created_at'],
                        domain: domain,
                        email: user['user']['email']
                      )
          u.external_person_id = ExternalPerson.get_or_create(webfinger).id
          return u
        end
      end
      nil
    end
  end
end
