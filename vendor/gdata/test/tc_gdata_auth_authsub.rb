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

$:.unshift(File.dirname(__FILE__))
require 'test_helper'

class TC_GData_Auth_AuthSub < Test::Unit::TestCase
  
  include TestHelper
  
  def test_make_authenticated_request
    token = self.get_authsub_token()
    key = self.get_authsub_private_key()
    service = GData::Client::YouTube.new
    if token
      
      service.authsub_token = token
      if key
        service.authsub_private_key = key
      end
      
      feed = service.get('http://gdata.youtube.com/feeds/api/users/default/uploads?max-results=1')
      self.assert_not_nil(feed, 'Feed should not be nil')
    end
  end
  
  def test_generate_url
    scope = 'http://gdata.youtube.com'
    next_url = 'http://example.com'
    secure = true
    session = false
    url = GData::Auth::AuthSub.get_url(next_url, scope, secure, session)
    self.assert_equal('https://www.google.com/accounts/AuthSubRequest?next=http%3A%2F%2Fexample.com&scope=http%3A%2F%2Fgdata.youtube.com&session=0&secure=1', url)
    
    # test generating with a pre-populated scope
    yt = GData::Client::YouTube.new
    client_url = yt.authsub_url(next_url, secure, session)
    self.assert_equal(url, client_url)
    
  end
  
end