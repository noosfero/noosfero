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

class TC_GData_HTTP_Request < Test::Unit::TestCase
  
  include TestHelper

  def test_world_is_sane
    assert(true, 'World is not sane.')
  end
  
  def test_google_is_live
    request = GData::HTTP::Request.new('http://www.google.com')
    
    service = GData::HTTP::DefaultService.new
    
    response = service.make_request(request)
    
    assert_equal(200, response.status_code)
  end
    
end