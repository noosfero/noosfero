require_relative "../test_helper"

class TicketTest < ActiveSupport::TestCase

  should 'have serialized data' do
    t = Ticket.new
    t.data[:test] = 'test'

    assert_equal({:test => 'test'}, t.data)
  end

end
