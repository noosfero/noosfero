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

  should 'be not nil the return get_html' do
    result = @parser.get_html("http://lattes.cnpq.br/2193972715230641")
    assert result.include?("Endereço para acessar este CV")
  end

  should 'inform that lattes was not found' do
    assert_equal "Lattes not found. Please, make sure the informed URL is correct.", @parser.get_html("http://lattes.cnpq.br/123")
  end
end
