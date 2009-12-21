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
    
    # Client class to wrap working with the YouTube API. Sets some 
    # YouTube-specific options.
    class YouTube < Base
      
      # The YouTube developer key being used.
      attr_accessor :developer_key
      # The YouTube ClientID being used.
      attr_accessor :client_id
      
      def initialize(options = {})
        options[:clientlogin_service] ||= 'youtube'
        options[:clientlogin_url] ||= 'https://www.google.com/youtube/accounts/ClientLogin'
        options[:authsub_scope] ||= 'http://gdata.youtube.com'
        options[:version] ||= '2'
        super(options)
      end
      
      # Custom prepare_headers to include the developer key and clientID
      def prepare_headers
        if @client_id
          @headers['X-GData-Client'] = @client_id
        end
        if @developer_key
          @headers['X-GData-Key'] = "key=#{@developer_key}"
        end
        super
      end
    end
  end
end