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
require 'openssl'
require 'base64'

module GData
  module Auth
    
    # This class implements AuthSub signatures for Data API requests.
    # It can be used with a GData::Client::GData object.
    class AuthSub
      
      # The URL of AuthSubRequest.
      REQUEST_HANDLER = 'https://www.google.com/accounts/AuthSubRequest'
      # The URL of AuthSubSessionToken.
      SESSION_HANDLER = 'https://www.google.com/accounts/AuthSubSessionToken'
      # The URL of AuthSubRevokeToken.
      REVOKE_HANDLER = 'https://www.google.com/accounts/AuthSubRevokeToken'
      # The URL of AuthSubInfo.
      INFO_HANDLER =  'https://www.google.com/accounts/AuthSubTokenInfo'
      # 2 ** 64, the largest 64 bit unsigned integer
      BIG_INT_MAX = 18446744073709551616
      
      # AuthSub access token.
      attr_accessor :token
      # Private RSA key used to sign secure requests.
      attr_reader :private_key
      
      # Initialize the class with a new token. Optionally pass a private
      # key or custom URLs.
      def initialize(token, options = {})
        if token.nil?
          raise ArgumentError, "Token cannot be nil."
        elsif token.class != String
          raise ArgumentError, "Token must be a String."
        end
        
        @token = token
        
        options.each do |key, value|
          self.send("#{key}=", value)
        end
      end
      
      # Set the private key to use with this AuthSub token.
      # The key can be an OpenSSL::PKey::RSA object, a string containing a
      # private key in PEM format, or a string specifying a path to a PEM
      # file that contains the private key.
      def private_key=(key)
        begin
          if key.nil? or key.class == OpenSSL::PKey::RSA
            @private_key = key
          elsif File.exists?(key)
            key_from_file = File.read(key)
            @private_key = OpenSSL::PKey::RSA.new(key_from_file)
          else
            @private_key = OpenSSL::PKey::RSA.new(key)
          end
        rescue
          raise ArgumentError, "Not a valid private key."
        end
      end
      
      # Sign a GData::Http::Request object with a valid AuthSub Authorization
      # header.
      def sign_request!(request)
        header = "AuthSub token=\"#{@token}\""
        
        if @private_key
          time = Time.now.to_i
          nonce = OpenSSL::BN.rand_range(BIG_INT_MAX)
          method = request.method.to_s.upcase
          data = "#{method} #{request.url} #{time} #{nonce}"
          sig = @private_key.sign(OpenSSL::Digest::SHA1.new, data)
          sig = Base64.encode64(sig).gsub(/\n/, '')
          header = "#{header} sigalg=\"rsa-sha1\" data=\"#{data}\""
          header = "#{header} sig=\"#{sig}\""
        end
        
        request.headers['Authorization'] = header
      end
      
      # Upgrade the current token into a session token.
      def upgrade
        request = GData::HTTP::Request.new(SESSION_HANDLER)
        sign_request!(request)
        service = GData::HTTP::DefaultService.new
        response = service.make_request(request)
        if response.status_code != 200
          raise GData::Client::AuthorizationError.new(response)
        end
        
        @token = response.body[/Token=(.*)/,1]
        return @token
        
      end
      
      # Return some information about the current token. If the current token
      # is a one-time use token, this operation will use it up!
      def info
        request = GData::HTTP::Request.new(INFO_HANDLER)
        sign_request!(request)
        service = GData::HTTP::DefaultService.new
        response = service.make_request(request)
        if response.status_code != 200
          raise GData::Client::AuthorizationError.new(response)
        end
        
        result = {}
        result[:target] = response.body[/Target=(.*)/,1]
        result[:scope] = response.body[/Scope=(.*)/,1]
        result[:secure] = response.body[/Secure=(.*)/,1]
        return result
       
      end
      
      # Revoke the token.
      def revoke
        request = GData::HTTP::Request.new(REVOKE_HANDLER)
        sign_request!(request)
        service = GData::HTTP::DefaultService.new
        response = service.make_request(request)
        if response.status_code != 200
          raise GData::Client::AuthorizationError.new(response)
        end

      end
      
      # Return the proper URL for an AuthSub approval page with the requested
      # scope. next_url should be a URL that points back to your code that
      # will receive the token. domain is optionally a Google Apps domain.
      def self.get_url(next_url, scope, secure = false, session = true, 
          domain = nil)
        next_url = CGI.escape(next_url)
        scope = CGI.escape(scope)
        secure = secure ? 1 : 0
        session = session ? 1 : 0
        body = "next=#{next_url}&scope=#{scope}&session=#{session}" +
               "&secure=#{secure}"
        if domain
          domain = CGI.escape(domain)
          body = "#{body}&hd=#{domain}"
        end
        return "#{REQUEST_HANDLER}?#{body}"
      end
    end
  end
end