require_relative '../test_helper'

class TinymceHelperTest < ActiveSupport::TestCase

  include TinymceHelper

  def setup
    expects(:tinymce).returns("")
    @environment = Environment.default
  end

  attr_accessor :top_url, :environment

  should 'set keep_styles to false in tinymce options' do
    environment.enable_plugin(CommentParagraphPlugin)
    expects(:base_options).with({:keep_styles => false})
    tinymce_editor
  end

  should 'do not set keep_styles to false when plugin is not enabled' do
    environment.disable_plugin(CommentParagraphPlugin)
    expects(:base_options).with({})
    tinymce_editor
  end

end
