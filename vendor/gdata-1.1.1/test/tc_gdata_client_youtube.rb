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

class TC_GData_Client_YouTube < Test::Unit::TestCase
  
  include TestHelper
  
  def setup
    @yt = GData::Client::YouTube.new
    self.assert(@yt.headers.empty?, 'headers should be empty.')
    @yt.clientlogin(self.get_username(), self.get_password())
    @yt.client_id = 'ytapi-Google-GDataUnitTests-lcqr3u89-1'
    @yt.developer_key = 'AI39si4vwXwDLR5MrtsdR1ULUD8__EnEccla-0bnqV40KpeFDIyCwEv0VJqZKHUsO3MvVM_bXHp3cAr55HmMYMhqfxzLMUgDXA'
  end
  
  def test_authenticated_uploads_feed
    
    
    feed = @yt.get('http://gdata.youtube.com/feeds/api/users/default/uploads?max-results=1').to_xml
    self.assert_not_nil(feed, 'feed can not be nil')
  end
  
  def test_favorites
    
    video_id = 'zlfKdbWwruY'
    
    entry = <<-EOF
    <entry xmlns="http://www.w3.org/2005/Atom">
      <id>#{video_id}</id>
    </entry>
    EOF
    
    response = @yt.post('http://gdata.youtube.com/feeds/api/users/default/favorites', entry).to_xml
    
    edit_uri = response.elements["link[@rel='edit']"].attributes['href']
    
    @yt.delete(edit_uri)
    
  end
  
  def test_playlist
    entry = <<-EOF
    <entry xmlns="http://www.w3.org/2005/Atom"
        xmlns:yt="http://gdata.youtube.com/schemas/2007">
      <title type="text">Ruby Utility Unit Test</title>
      <summary>This is a test playlist.</summary>
    </entry>
    EOF
    
    response = @yt.post('http://gdata.youtube.com/feeds/api/users/default/playlists', entry).to_xml
    
    edit_uri = response.elements["link[@rel='edit']"].attributes['href']
    
    response.elements["summary"].text = "Updated description"
    
    response = @yt.put(edit_uri, response.to_s).to_xml
    
    self.assert_equal("Updated description", response.elements["summary"].text)
    
    @yt.delete(edit_uri)
  end
  
end