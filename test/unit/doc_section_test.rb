require 'test_helper'

class DocSectionTest < ActiveSupport::TestCase
  should 'be a DocItem' do
    assert_kind_of DocItem, DocSection.new
  end

  should 'have a list of items' do
    assert_kind_of Array, DocSection.new.items
  end

  should 'be able to add items' do
    section = DocSection.new
    item = DocItem.new(:title => 'test')
    section.items << item
    assert_equal item, section.items.first
  end

  # This test assumes the existance of some sample documentation sections. If
  # they are removed or retitled this test will break
  should 'list available sections' do
    sections = DocSection.all
    assert(sections.size > 0, 'should load sections ')
    assert(sections.find { |item| item.title == 'Administration'}, 'should find section "Administration"')
    assert(sections.find { |item| item.title == 'User features'}, 'should find section "User features"')
  end

  # This test assumes the same as the above test, plus a specific translation
  # for the section names. If the test above breaks, this one will probably
  # break. If those translations change, this test will also break.
  should 'list section for a given language' do
    sections = DocSection.all('pt')
    assert(sections.find { |item| item.title == 'Administração'}, 'should find section "Administration" translated')
    assert(sections.find { |item| item.title == 'Funcionalidades de Usuário'}, 'should find section "User features" translated')
  end

  should 'indicate the language when loading sections' do
    DocSection.all.each do |section|
      assert_equal 'en', section.language, 'should indicate default language'
    end
    DocSection.all('pt').each do |section|
      assert_equal 'pt', section.language, 'should indicate Portuguese'
    end
  end

  # This test also depends on the existance of specific documentation sections.
  # The same conditions as the above tests apply.
  should 'list items' do
    section = DocSection.all.find {|item| item.title == 'Administration' }
    assert section.items.size > 0, "should load at least one item"
    assert section.items.find {|item| item.title == 'E-mail settings' && item.text =~ /<h1>E-mail settings/ }, 'should find "E-mail settings" topic'
    assert section.items.find {|item| item.title == 'Managing user roles' && item.text =~ /<h1>Managing/ }, 'should find "Managing user roles" topic'
  end

  # This test assumes ... (yada, yada, yada, the same as above)
  should 'load translated items' do
    section = DocSection.all('pt').find {|item| item.title == 'Administração' }
    assert section.items.size > 0, "should load at least one item"
    assert section.items.find {|item| item.title == 'Configurações de e-mail' && item.text =~ /<h1>Configurações/ }, 'should find translated "E-mail settings" topic'
    assert section.items.find {|item| item.title == 'Gerenciando papéis de usuários' && item.text =~ /<h1>Gerenciando/ }, 'should find translated "Managing user roles" topic'
  end

  # This test assumes that Klingon (tlh) is not supported. If Noosfero does get
  # aa Klingon translation, then this test will fail
  should 'fallback to load original items when translation is not available' do
    section = DocSection.find('admin', 'tlh')
    assert_equal 'Administration', section.title

    topic = section.find('100-email')
    assert_equal 'E-mail settings', topic.title
  end

  should 'find in items' do
    section = DocSection.new
    item1 = DocItem.new(:id => 'item1')
    item2 = DocItem.new(:id => 'item2')
    section.items << item1 << item2
    assert_equal item1, section.find('item1')
    assert_equal item2, section.find('item2')
  end

  should 'be able to find section by its id' do
    assert_equal "Administration", DocSection.find('admin').title
    assert_equal "User features", DocSection.find('user').title
  end

  should 'load null section (the root)' do
    [nil, ''].each do |key|
      section = DocSection.find(nil)
      assert_equal "#{RAILS_ROOT}/doc/noosfero", section.send(:directory)
    end
  end

  should 'not load null section (the root) for unexisting sections' do
    assert_nil DocSection.find('something-very-unlikely')
  end

end
