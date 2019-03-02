require 'test_helper'

class ChatMessageTest < ActiveSupport::TestCase
  should 'create message' do
    assert_difference 'ChatMessage.count', 1 do
      ChatMessage.create!(:from => fast_create(Person), :to => fast_create(Person), :body => 'Hey! How are you?' )
    end
  end
end
