# encoding: UTF-8
require 'mocha'

module Noosfero::DocTest

  unless defined?(ROOT)
    ROOT = Rails.root.join("test", "tmp", "doc")
  end

  def create_doc(section, topic, language, title, body = nil)
    dir = File.join(ROOT, section)
    FileUtils.mkdir_p(dir)
    File.open("#{dir}/#{topic}.#{language}.xhtml", "w") do |f|
      f.puts "<h1>#{title}</h1>"
      f.puts body
    end
  end

  def setup_doc_test
    FileUtils.mkdir_p(ROOT)

    # root
    create_doc('', 'index', 'en', 'Noosfero online manual')
    create_doc('', 'toc', 'en', '', '<ul><li><a href="/doc/user">User features</a></li><li><a href="/doc/cms">Content Management</a></li></ul>')
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
    create_doc('user', 'toc', 'en', '<ul><li><a href="/doc/user/commenting-articles">Commenting articles</a></li><li><a href="/doc/user/acceptins-friends">Accepting friends</a></li></ul>')
    create_doc('user', 'toc', 'pt', '')
    create_doc('user', 'accepting-friends', 'en', 'Accepting friends')
    create_doc('user', 'accepting-friends', 'pt', 'Aceitando amigos')
    create_doc('user', 'commenting-articles', 'en', 'Commenting articles', 'How to access')
    create_doc('user', 'commenting-articles', 'pt', 'Comentando artigos')

    DocSection.stubs(:root_dir).returns(ROOT)
  end

  def tear_down_doc_test
    FileUtils.rm_rf(ROOT)
  end
end
