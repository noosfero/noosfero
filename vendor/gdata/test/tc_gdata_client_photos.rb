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

class TC_GData_Client_Photos < Test::Unit::TestCase
  
  include TestHelper
  
  def setup
    @gp = GData::Client::Photos.new
    @gp.source = 'Ruby Client Unit Tests'
    @gp.clientlogin(self.get_username(), self.get_password())
  end
  
  def test_authenticated_dropbox_feed
    feed = @gp.get('http://picasaweb.google.com/data/feed/api/user/default/albumid/default?max-results=1').to_xml
    self.assert_not_nil(feed, 'feed can not be nil')
  end
  
  def test_photo_upload
    test_image = File.join(File.dirname(__FILE__), 'testimage.jpg')
    mime_type = 'image/jpeg'
    
    response = @gp.post_file('http://picasaweb.google.com/data/feed/api/user/default/albumid/default', 
      test_image, mime_type).to_xml
    
    edit_uri = response.elements["link[@rel='edit']"].attributes['href']
    
    @gp.delete(edit_uri)
  end
  
  def test_photo_upload_with_metadata
    test_image = File.join(File.dirname(__FILE__), 'testimage.jpg')
    mime_type = 'image/jpeg'
    
    entry = <<-EOF
    <entry xmlns='http://www.w3.org/2005/Atom'>
      <title>ruby-client-testing.jpg</title>
      <summary>Test case for Ruby Client Library.</summary>
      <category scheme="http://schemas.google.com/g/2005#kind"
        term="http://schemas.google.com/photos/2007#photo"/>
    </entry>
    EOF
    
    response = @gp.post_file('http://picasaweb.google.com/data/feed/api/user/default/albumid/default', 
      test_image, mime_type, entry).to_xml
    
    edit_uri = response.elements["link[@rel='edit']"].attributes['href']
    
    @gp.delete(edit_uri)
  end
end