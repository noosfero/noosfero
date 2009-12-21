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
    
    # Client class to wrap working with the Calendar Data API.
    class Calendar < Base
      
      # Holds on to a session cookie
      attr_accessor :session_cookie
      
      def initialize(options = {})
        options[:clientlogin_service] ||= 'cl'
        options[:authsub_scope] ||= 'http://www.google.com/calendar/feeds/'
        super(options)
      end
      
      # Overrides auth_handler= so if the authentication changes,
      # the session cookie is cleared.
      def auth_handler=(handler)
        @session_cookie = nil
        return super(handler)
      end
      
      # Overrides make_request to handle 302 redirects with a session cookie.
      def make_request(method, url, body = '', retries = 4)
        response = super(method, url, body)
        if response.status_code == 302 and retries > 0
          @session_cookie = response.headers['set-cookie']
          return self.make_request(method, url, body, 
            retries - 1)
        else
          return response
        end
      end
      
      # Custom prepare_headers to include the session cookie if it exists
      def prepare_headers
        if @session_cookie
          @headers['cookie'] = @session_cookie
        end
        super
      end
    end
  end
end