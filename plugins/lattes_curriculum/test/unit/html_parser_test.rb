#!/bin/env ruby
# encoding: utf-8

require "test_helper"

class HtmlParserTest < ActiveSupport::TestCase

  def setup
    @parser = Html_parser.new
  end

  should 'be not nil the instance' do
    assert_not_nil @parser
  end
end
