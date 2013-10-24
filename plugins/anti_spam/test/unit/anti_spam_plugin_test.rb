require 'test_helper'

class AntiSpamPluginTest < ActiveSupport::TestCase

  class Spammable
    attr_accessor :spam

    def save!; end
    def spam!; end
    def ham!; end
    def spam?; true; end
    def environment; Environment.default; end
  end

  def setup
    @spammable = Spammable.new
    @plugin = AntiSpamPlugin.new
  end

  attr_accessor :spammable

  should 'check for spam and mark as spam if server says it is spam' do
    spammable.expects(:save!)

    @plugin.check_for_spam(spammable)
    assert spammable.spam
  end

  should 'report comment spam' do
    spammable.expects(:spam!)
    @plugin.marked_as_spam(spammable)
  end

  should 'report comment ham' do
    spammable.expects(:ham!)
    @plugin.marked_as_ham(spammable)
  end
end
