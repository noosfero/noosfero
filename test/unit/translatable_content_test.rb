require_relative "../test_helper"

class TranslatableContentTest < ActiveSupport::TestCase

  class Content
    attr_accessor :parent, :profile
    include Noosfero::TranslatableContent
  end

  def setup
    @content = Content.new
  end
  attr_reader :content

  should 'be translatable if no parent' do
    assert content.translatable?
  end

  should 'not be translatable if parent is a forum' do
    content.parent = Forum.new
    assert !content.translatable?
  end

  should 'be translatable if parent is not a forum' do
    content.parent = Blog.new
    assert content.translatable?
  end

end
