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

class TC_GData_Client_Base < Test::Unit::TestCase
  
  include TestHelper
  
  def test_simple_gdata_get
    service = GData::Client::Base.new
    feed = service.get('http://gdata.youtube.com/feeds/base/videos?max-results=1').to_xml
    assert_not_nil(feed, 'feed can not be nil')
  end
  
  def test_clientlogin_with_service
    service = GData::Client::Base.new
    service.clientlogin(self.get_username(), self.get_password(), nil, nil, 
      'youtube')
    feed = service.get('http://gdata.youtube.com/feeds/api/users/default/uploads?max-results=1').to_xml
    assert_not_nil(feed, 'feed can not be nil')
  end
  
end
    