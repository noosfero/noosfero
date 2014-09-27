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

class TC_GData_Client_Calendar < Test::Unit::TestCase
  
  include TestHelper
  
  def setup
    @cl = GData::Client::Calendar.new
    @cl.clientlogin(self.get_username, self.get_password)
  end
  
  def test_get_all_calendars    
    response = @cl.get('http://www.google.com/calendar/feeds/default/allcalendars/full')
    self.assert_equal(200, response.status_code, 'Must not be a redirect.')
    self.assert_not_nil(@cl.session_cookie, 'Must have a session cookie.')
    feed = response.to_xml
    self.assert_not_nil(feed, 'feed can not be nil')
    
    #login again to make sure the session cookie gets cleared
    @cl.clientlogin(self.get_username, self.get_password)
    self.assert_nil(@cl.session_cookie, 'Should clear session cookie.')
  end

  
end