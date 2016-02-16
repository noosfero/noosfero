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

class TC_GData_HTTP_MimeBody < Test::Unit::TestCase
  
  include TestHelper

  def test_mime_body_string
    stream = GData::HTTP::MimeBodyString.new('testing 1 2 3')
    
    self.assert_equal('t', stream.read(1))
    self.assert_equal('esting', stream.read(6))
    self.assert_equal(' 1 2 ', stream.read(5))
    self.assert_equal('3', stream.read(50))
    self.assert_equal(false, stream.read(10))
  end
  
  def test_mime_body_string_large_read
    stream = GData::HTTP::MimeBodyString.new('test string')
    
    self.assert_equal('test string', stream.read(1024))
    self.assert_equal(false, stream.read(1024))
  end
  
  def test_mime_body_string_unicode
    stream = GData::HTTP::MimeBodyString.new('λ')
    self.assert(stream.read(1), 'Greek character should be two bytes')
    self.assert(stream.read(1), 'Greek character should be two full bytes')
    self.assert_equal(false, stream.read(1))
  end

end