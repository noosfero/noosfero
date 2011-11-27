require File.dirname(__FILE__) + '/../test_helper'

class TagsHelperTest < ActiveSupport::TestCase

  include ApplicationHelper
  include TagsHelper
  include ActionController::UrlWriter

  def h(s); s; end
  def link_to(text, *args); text; end

  should 'order tags alphabetically' do
    result = tag_cloud(
      { 'tag1'=>9, 'Tag3'=>2, 'Tag2'=>2, 'aTag'=>2, 'beTag'=>2 },
      :id,
      { :host=>'noosfero.org', :controller=>'test', :action=>'tag' }
    )
    assert_equal %w(aTag beTag tag1 Tag2 Tag3).join("\n"), result
  end

end
