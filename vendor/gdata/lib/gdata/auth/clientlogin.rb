# Copyright (C) 2008 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cgi'

module GData
  module Auth
    
    # This class implements ClientLogin signatures for Data API requests.
    # It can be used with a GData::Client::GData object.
    class ClientLogin
      
      # The ClientLogin authentication handler
      attr_accessor :auth_url
      # One of 'HOSTED_OR_GOOGLE', 'GOOGLE', or 'HOSTED'. 
      # See documentation here: 
      # http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html
      attr_accessor :account_type
      # The access token
      attr_accessor :token
      # The service name for the API you are working with
      attr_accessor :service
      
      # Initialize the class with the service name of an API that you wish
      # to request a token for.
      def initialize(service, options = {})
        if service.nil?
          raise ArgumentError, "Service name cannot be nil"
        end
        
        @service = service
        
        options.each do |key, value|
          self.send("#{key}=", value)
        end
        
        @auth_url ||= 'https://www.google.com/accounts/ClientLogin'
        @account_type ||= 'HOSTED_OR_GOOGLE'
      end
      
      # Retrieves a token for the given username and password.
      # source identifies your application.
      # login_token and login_captcha are used only if you are responding
      # to a previously issued CAPTCHA challenge.
      def get_token(username, password, source, login_token = nil, 
          login_captcha = nil)
        body = Hash.new
        body['accountType'] = @account_type
        body['Email'] = username
        body['Passwd'] = password
        body['service'] = @service
        body['source'] = source
        if login_token and login_captcha
          body['logintoken'] = login_token
          body['logincaptcha'] = login_captcha
        end
        
        request = GData::HTTP::Request.new(@auth_url, :body => body, 
          :method => :post)
        service = GData::HTTP::DefaultService.new
        response = service.make_request(request)
        if response.status_code != 200
          url = response.body[/Url=(.*)/,1]
          error = response.body[/Error=(.*)/,1]
          
          if error == "CaptchaRequired"
            captcha_token = response.body[/CaptchaToken=(.*)/,1]
            captcha_url = response.body[/CaptchaUrl=(.*)/,1]
            raise GData::Client::CaptchaError.new(captcha_token, captcha_url), 
              "#{error} : #{url}"
          end
          
          raise GData::Client::AuthorizationError.new(response)
        end
        
        @token = response.body[/Auth=(.*)/,1]
        return @token
      end
      
      # Creates an appropriate Authorization header on a GData::HTTP::Request
      # object.
      def sign_request!(request)
        if @token == nil
          raise GData::Client::Error, "Cannot sign request without credentials"
        end
        
        request.headers['Authorization'] = "GoogleLogin auth=#{@token}" 
      end
    end
  end
end