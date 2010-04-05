module Noosfero::DocTest

  ROOT = File.join(Rails.root, "test", "tmp", "doc")

  def create_doc(section, topic, language, title)
    dir = File.join(ROOT, section)
    FileUtils.mkdir_p(dir)
    File.open("#{dir}/#{topic}.#{language}.xhtml", "w") do |f|
      f.puts "<h1>#{title}</h1>"
    end
  end

  def setup_doc_test
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
    create_doc('user', 'accepting-friends', 'pt', 'Aceitando amigos')

    DocSection.stubs(:root_dir).returns(ROOT)
  end

  def tear_down_doc_test
    FileUtils.rm_rf(ROOT)
  end
end
