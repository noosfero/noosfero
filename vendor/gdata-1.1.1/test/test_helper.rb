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

require 'yaml'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'gdata'

module TestHelper
  
  def get_config()
    if not defined?(@config_file)
      @config_file = YAML::load_file(File.join(File.dirname(__FILE__), 'test_config.yml'))
    end
    return @config_file
  end
  
  def get_username()
    return self.get_config()['username']
  end
  
  def get_password()
    return self.get_config()['password']
  end
  
  def get_authsub_token()
    return self.get_config()['authsub_token']
  end
  
  def get_authsub_private_key()
    return self.get_config()['authsub_private_key']
  end
  
end