class AddPeopleAndArticleEditor < ActiveRecord::Migration
  def change
    add_column :profiles, :editor, :string, :null => false, :default => Article::Editor::TINY_MCE
    add_column :articles, :editor, :string, :null => false, :default => Article::Editor::TINY_MCE
    Article.where(:type => 'TextileArticle').update_all(:type => 'TextArticle', :editor => Article::Editor::TEXTILE)
    Article.where(:type => 'TinyMceArticle').update_all(:type => 'TextArticle', :editor => Article::Editor::TINY_MCE)
    Article.where(:type => 'RawHTMLArticle').update_all(:type => 'TextArticle', :editor => Article::Editor::RAW_HTML)
  end
end
