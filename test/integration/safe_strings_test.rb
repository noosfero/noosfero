require_relative "../test_helper"

class SafeStringsTest < ActionDispatch::IntegrationTest

  should 'not escape link to admins on profile page' do
    person = fast_create Person
    community = fast_create Community
    community.add_admin(person)
    get "/profile/#{community.identifier}"
    assert_tag :tag => 'td', :content => 'Admins', :sibling => {
      :tag => 'td', :child => { :tag => 'a', :content => person.name }
    }
  end

  should 'not escape people names on members block' do
    person = fast_create Person
    community = fast_create Community
    community.add_member(person)
    community.boxes << Box.new
    community.boxes.first.blocks << MembersBlock.new
    get "/profile/#{community.identifier}"
    assert_tag :tag => 'div', :attributes => { :id => "block-#{community.blocks.first.id}" }, :descendant => {
      :tag => 'li', :attributes => { :class => 'vcard' }, :content => person.name
    }
  end

  should 'not escape RawHTMLBlock content' do
    community = fast_create Community
    community.boxes << Box.new
    community.boxes.first.blocks << RawHTMLBlock.new(:html => '<b>bold</b>')
    get "/profile/#{community.identifier}"
    assert_tag :tag => 'div', :attributes => { :id => "block-#{community.blocks.first.id}" }, :descendant => {
      :tag => 'b', :content => 'bold'
    }
  end

  should 'not escape profile header or footer' do
    community = fast_create Community
    community.update_header_and_footer('<b>header</b>', '<b>footer</b>')
    get "/profile/#{community.identifier}"
    assert_tag :tag => 'div', :attributes => { :id => 'profile-header' }, :child => { :tag => 'b', :content => 'header' }
    assert_tag :tag => 'div', :attributes => { :id => 'profile-footer' }, :child => { :tag => 'b', :content => 'footer' }
  end

  should 'not escape &rarr; symbol from categories' do
    create_user('marley', :password => 'test', :password_confirmation => 'test').activate
    category = fast_create Category
    subcategory = fast_create(Category, :parent_id => category.id)
    Person['marley'].categories << subcategory
    login 'marley', 'test'
    get "/myprofile/marley/profile_editor/edit"
    assert_tag :tag => 'a', :attributes => { :id => "remove-selected-category-#{subcategory.id}-button" },
      :content => "#{category.name} &rarr; #{subcategory.name}"
  end

  should 'not escape MainBlock on profile design' do
    create_user('jimi', :password => 'test', :password_confirmation => 'test').activate
    jimi = Person['jimi']
    jimi.boxes << Box.new
    jimi.boxes.first.blocks << MainBlock.new
    login 'jimi', 'test'
    get "/myprofile/jimi/profile_design"
    assert_tag :tag => 'div', :attributes => { :class => 'main-content' }, :content => '&lt;Main content&gt;'
  end

  should 'not escape confirmation message on deleting folders' do
    create_user('jimi', :password => 'test', :password_confirmation => 'test').activate
    fast_create(Folder, :name => 'Hey Joe', :profile_id => Person['jimi'].id, :updated_at => DateTime.now)
    login 'jimi', 'test'
    get "/myprofile/jimi/cms"
    assert_tag :tag => 'a', :attributes => {
      'data-confirm' => /Are you sure that you want to remove the folder &quot;Hey Joe&quot;\?/
    }
  end

  should 'not escape people names on manage friends' do
    create_user('jimi', :password => 'test', :password_confirmation => 'test').activate
    friend = fast_create Person
    Person['jimi'].add_friend(friend)
    login 'jimi', 'test'
    get '/myprofile/jimi/friends'
    assert_tag :tag => 'div', :attributes => { :id => 'manage_friends' }, :descendant => {
      :tag => 'a', :attributes => { :class => 'profile-link' }, :content => friend.name
    }
  end

end
