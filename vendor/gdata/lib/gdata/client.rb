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

require 'gdata/client/base'
require 'gdata/client/apps'
require 'gdata/client/blogger'
require 'gdata/client/booksearch'
require 'gdata/client/calendar'
require 'gdata/client/contacts'
require 'gdata/client/doclist'
require 'gdata/client/finance'
require 'gdata/client/gbase'
require 'gdata/client/gmail'
require 'gdata/client/health'
require 'gdata/client/notebook'
require 'gdata/client/photos'
require 'gdata/client/spreadsheets'
require 'gdata/client/webmaster_tools'
require 'gdata/client/youtube'
  
module GData
  module Client

    # Base class for GData::Client errors
    class Error < RuntimeError
    end

    # Base class for errors raised due to requests
    class RequestError < Error

      # The Net::HTTPResponse that caused this error.
      attr_accessor :response

      # Creates a new RequestError from Net::HTTPResponse +response+ with a
      # message containing the error code and response body.
      def initialize(response)
        @response = response

        super "request error #{response.status_code}: #{response.body}"
      end

    end

    class AuthorizationError < RequestError
    end
    
    class BadRequestError < RequestError
    end
    
    # An error caused by ClientLogin issuing a CAPTCHA error.
    class CaptchaError < RuntimeError
      # The token identifying the CAPTCHA
      attr_reader :token
      # The URL to the CAPTCHA image
      attr_reader :url
      
      def initialize(token, url)
        @token = token
        @url = url
      end
    end
    
    class ServerError < RequestError
    end
    
    class UnknownError < RequestError
    end
    
    class VersionConflictError < RequestError
    end  
    
  end
end