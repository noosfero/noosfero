require 'test_helper'

class DocSectionTest < ActiveSupport::TestCase

  ROOT = File.join(Rails.root, "test", "tmp", "doc")

  def create_doc(section, topic, language, title)
    dir = File.join(ROOT, section)
    FileUtils.mkdir_p(dir)
    File.open("#{dir}/#{topic}.#{language}.xhtml", "w") do |f|
      f.puts "<h1>#{title}</h1>"
    end
  end

  def setup
    FileUtils.mkdir_p(ROOT)

    # root
    create_doc('', 'index', 'en', 'Root')
    create_doc('', 'toc', 'en', 'Root')
    # cms
    create_doc('cms', 'index', 'en', 'Content Management')
    create_doc('cms', 'index', 'pt', 'Gerenciamento de conteúdo')
    create_doc('cms', 'toc', 'en', '')
    create_doc('cms', 'toc', 'pt', '')
    create_doc('cms', 'adding-pictures', 'en', 'Adding pictures to gallery')
    create_doc('cms', 'adding-pictures', 'pt', 'Adicionando fotos na galeria')
    create_doc('cms', 'creating-a-blog', 'en', 'Creating a blog')
    create_doc('cms', 'creating-a-blog', 'pt', 'Criando um blog')
    # user
    create_doc('user', 'index', 'en', 'User features')
    create_doc('user', 'index', 'pt', 'Funcionalidades de Usuário')
    create_doc('user', 'toc', 'en', '')
    create_doc('user', 'toc', 'pt', '')
    create_doc('user', 'accepting-friends', 'en', 'Accepting friends')

    DocSection.stubs(:root_dir).returns(ROOT)
  end

  def tear_down
    FileUtils.rm_rf(ROOT)
  end

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
    assert(sections.find { |item| item.title == 'Content Management'}, 'should find section "Content Management"')
    assert(sections.find { |item| item.title == 'User features'}, 'should find section "User features"')
  end

  # This test assumes the same as the above test, plus a specific translation
  # for the section names. If the test above breaks, this one will probably
  # break. If those translations change, this test will also break.
  should 'list section for a given language' do
    sections = DocSection.all('pt')
    assert(sections.find { |item| item.title == 'Gerenciamento de conteúdo'}, 'should find section "Content Management" translated')
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
    section = DocSection.all.find {|item| item.title == 'Content Management' }
    assert section.items.size > 0, "should load at least one item"
    assert section.items.find {|item| item.title == 'Adding pictures to gallery' && item.text =~ /<h1>Adding pictures to gallery/ }, 'should find "Adding pictures to gallery" topic'
    assert section.items.find {|item| item.title == 'Creating a blog' && item.text =~ /<h1>Creating a blog/ }, 'should find "Creating a blog" topic'
  end

  # This test assumes ... (yada, yada, yada, the same as above)
  should 'load translated items' do
    section = DocSection.all('pt').find {|item| item.title == 'Gerenciamento de conteúdo' }
    assert section.items.size > 0, "should load at least one item"
    assert section.items.find {|item| item.title == 'Adicionando fotos na galeria' && item.text =~ /<h1>Adicionando fotos na galeria/ }, 'should find translated "Adding pictures to gallery" topic'
    assert section.items.find {|item| item.title == 'Criando um blog' && item.text =~ /<h1>Criando um blog/ }, 'should find translated "Creating a blog" topic'
  end

  # This test assumes that Klingon (tlh) is not supported. If Noosfero does get
  # aa Klingon translation, then this test will fail
  should 'fallback to load original items when translation is not available' do
    section = DocSection.find('user', 'tlh')
    assert_equal 'User features', section.title

    topic = section.find('accepting-friends')
    assert_equal 'Accepting friends', topic.title
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
    assert_equal "User features", DocSection.find('user').title
    assert_equal "Content Management", DocSection.find('cms').title
  end

  should 'load null section (the root)' do
    [nil, ''].each do |key|
      section = DocSection.find(nil)
      assert_equal DocSection.root_dir, section.send(:directory)
    end
  end

  should 'raise DocItem::NotFound when loading unexisting section' do
    assert_raise DocItem::NotFound do
      DocSection.find('something-very-unlikely')
    end
  end

  should 'raise DocTopic::NotFound when trying to find an unexisting topic inside a section' do
    section = DocSection.all.first
    assert_raise DocItem::NotFound do
      section.find('unexisting')
    end
  end


end
