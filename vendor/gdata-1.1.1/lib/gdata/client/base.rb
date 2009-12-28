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

module GData
  module Client
    
    # A client object used to interact with different Google Data APIs.
    class Base
    
      # A subclass of GData::Auth that handles authentication signing.
      attr_accessor :auth_handler
      # A subclass of GData::HTTP that handles making HTTP requests.
      attr_accessor :http_service
      # Headers to include in every request.
      attr_accessor :headers
      # The API version being used.
      attr_accessor :version
      # The default URL for ClientLogin.
      attr_accessor :clientlogin_url
      # A default service name for ClientLogin (overriden by subclasses).
      attr_accessor :clientlogin_service
      # The broadest AuthSub scope for working with an API.
      # This is overriden by the service-specific subclasses.
      attr_accessor :authsub_scope
      # A short string identifying the current application.
      attr_accessor :source
      
      def initialize(options = {})
        options.each do |key, value|
          self.send("#{key}=", value)
        end
        
        @headers ||= {}
        @http_service ||= GData::HTTP::DefaultService
        @version ||= '2'
        @source ||= 'AnonymousApp'
      end
      
      # Sends an HTTP request with the given file as a stream
      def make_file_request(method, url, file_path, mime_type, entry = nil)
        if not File.readable?(file_path)
          raise ArgumentError, "File #{file_path} is not readable."
        end
        file = File.open(file_path, 'rb')
        @headers['Slug'] = File.basename(file_path)
        if entry
          @headers['MIME-Version'] = '1.0'
          body = GData::HTTP::MimeBody.new(entry, file, mime_type)
          @headers['Content-Type'] = body.content_type
          response = self.make_request(method, url, body)
        else
          @headers['Content-Type'] = mime_type
          response = self.make_request(method, url, file)
        end
        file.close
        return response
      end
      
      # Sends an HTTP request and return the response.
      def make_request(method, url, body = '')
        headers = self.prepare_headers
        request = GData::HTTP::Request.new(url, :headers => headers, 
          :method => method, :body => body)
        
        if @auth_handler and @auth_handler.respond_to?(:sign_request!)
          @auth_handler.sign_request!(request)
        end

        service = http_service.new
        response = service.make_request(request)
        
        case response.status_code  
        when 200, 201, 302
          #Do nothing, it's a success.
        when 401, 403
          raise AuthorizationError.new(response)
        when 400
          raise BadRequestError.new(response)
        when 409
          raise VersionConflictError.new(response)
        when 500
          raise ServerError.new(response)
        else
          raise UnknownError.new(response)
        end
        
        return response
      end
      
      # Performs an HTTP GET against the API.
      def get(url)
        return self.make_request(:get, url)
      end
      
      # Performs an HTTP PUT against the API.
      def put(url, body)
        return self.make_request(:put, url, body)
      end
      
      # Performs an HTTP PUT with the given file
      def put_file(url, file_path, mime_type, entry = nil)
        return self.make_file_request(:put, url, file_path, mime_type, entry)
      end
      
      # Performs an HTTP POST against the API.
      def post(url, body)
        return self.make_request(:post, url, body)
      end
      
      # Performs an HTTP POST with the given file
      def post_file(url, file_path, mime_type, entry = nil)
        return self.make_file_request(:post, url, file_path, mime_type, entry)
      end
      
      # Performs an HTTP DELETE against the API.
      def delete(url)
        return self.make_request(:delete, url)
      end
      
      # Constructs some necessary headers for every request.
      def prepare_headers
        headers = @headers
        headers['GData-Version'] = @version
        headers['User-Agent'] = GData::Auth::SOURCE_LIB_STRING + @source
        # by default we assume we are sending Atom entries
        if not headers.has_key?('Content-Type')
          headers['Content-Type'] = 'application/atom+xml'
        end
        return headers
      end
      
      # Performs ClientLogin for the service. See GData::Auth::ClientLogin
      # for details.
      def clientlogin(username, password, captcha_token = nil, 
        captcha_answer = nil, service = nil, account_type = nil)
        if service.nil?
          service = @clientlogin_service
        end
        options = { :account_type => account_type }
        self.auth_handler = GData::Auth::ClientLogin.new(service, options)
        if @clientlogin_url
          @auth_handler.auth_url = @clientlogin_url
        end
        source = GData::Auth::SOURCE_LIB_STRING + @source
        @auth_handler.get_token(username, password, source, captcha_token, captcha_answer)
      end
      
      def authsub_url(next_url, secure = false, session = true, domain = nil,
        scope = nil)
        if scope.nil?
          scope = @authsub_scope
        end
        GData::Auth::AuthSub.get_url(next_url, scope, secure, session, domain)
      end
      
      # Sets an AuthSub token for the service.
      def authsub_token=(token)
        self.auth_handler = GData::Auth::AuthSub.new(token)
      end
      
      # Sets a private key to use with AuthSub requests.
      def authsub_private_key=(key)
        if @auth_handler.class == GData::Auth::AuthSub
          @auth_handler.private_key = key
        else
          raise Error, "An AuthSub token must be set first."
        end
      end
    end
  end
end
