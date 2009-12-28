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

require 'gdata/client'

module GData
  module HTTP
  
    # An extremely simple class to hold the values of an HTTP response.
    class Response
    
      # The HTTP response code.
      attr_accessor :status_code
      # The body of the HTTP response.
      attr_accessor :body
      # The headers of the HTTP response.
      attr_accessor :headers
      
      # Converts the response body into a REXML::Document
      def to_xml
        if @body
          begin
            return REXML::Document.new(@body).root
          rescue
            raise GData::Client::Error, "Response body not XML."
          end
        else
          return nil
        end
      end
    end
  end
end