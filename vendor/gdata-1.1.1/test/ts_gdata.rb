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
require 'ts_gdata_http'
require 'ts_gdata_client'
require 'ts_gdata_auth'

class TS_GData
  def self.suite
    suite = Test::Unit::TestSuite.new("GData Test Suite")
    suite << UnicodeStringTest.suite
    suite << TS_GData_HTTP.suite
    suite << TS_GData_Client.suite
    suite << TS_GData_Auth.suite
    return suite
  end
end

class UnicodeStringTest < Test::Unit::TestCase
  def test_jlength
    s = "Καλημέρα κόσμε!"
    assert_equal(15, s.jlength) # Note the 'j'
    assert_not_equal(15, s.length) # Normal, non unicode length
    assert_equal(28, s.length) # Greek letters happen to take two-bytes
  end
end


Test::Unit::UI::Console::TestRunner.run(TS_GData)