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

require "rexml/document"

module GData
  module HTTP
  
    # Very simple class to hold everything about an HTTP request.
    class Request
    
      # The URL of the request.
      attr_accessor :url
      # The body of the request.
      attr_accessor :body
      # The HTTP method being used in the request.
      attr_accessor :method
      # The HTTP headers of the request.
      attr_accessor :headers
      
      # Only the URL itself is required, everything else is optional.
      def initialize(url, options = {})
        @url = url
        options.each do |key, value|
          self.send("#{key}=", value)
        end
        
        @method ||= :get
        @headers ||= {}
      end
      
      # Returns whether or not a request is chunked.
      def chunked?
        if @headers['Transfer-Encoding'] == 'chunked'
          return true
        else
          return false
        end
      end
      
      # Sets if the request is using chunked transfer-encoding.
      def chunked=(enabled)
        if enabled
          @headers['Transfer-Encoding'] = 'chunked'
        else
          @headers.delete('Transfer-Encoding')
        end
      end
      
      # Calculates and sets the length of the body.
      def calculate_length!
        if not @headers['Content-Length'] and not chunked? \
          and method != :get and method != :delete
          if @body
            @headers['Content-Length'] = @body.length
          else
            @headers['Content-Length'] = 0
          end
        end
      end
    end
  end
end