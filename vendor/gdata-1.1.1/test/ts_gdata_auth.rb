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

require 'tc_gdata_auth_clientlogin'
require 'tc_gdata_auth_authsub'

class TS_GData_Auth
  def self.suite
    suite = Test::Unit::TestSuite.new
    suite << TC_GData_Auth_ClientLogin.suite
    suite << TC_GData_Auth_AuthSub.suite
    return suite
  end
end