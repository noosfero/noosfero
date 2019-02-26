# encoding: UTF-8
require_relative "../../../test_helper"

class Entitlement::Checks::VisitorTest < ActiveSupport::TestCase
  def setup
    @check = Entitlement::Checks::Visitor.new
  end

  attr_reader :check

  should 'entitle always' do
    assert check.entitles?(nil)
  end
end
