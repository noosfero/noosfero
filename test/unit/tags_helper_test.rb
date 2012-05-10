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

  should 'order tags alphabetically with special characters' do
    result = tag_cloud(
      { 'aula'=>9, 'área'=>2, 'area'=>2, 'avião'=>2, 'armário'=>2,
        'A'=>1, 'Á'=>1, 'AB'=>1, 'ÁA'=>1 },
      :id,
      { :host=>'noosfero.org', :controller=>'test', :action=>'tag' }
    )
    assert_equal %w(A Á ÁA AB area área armário aula avião).join("\n"), result
  end

end
