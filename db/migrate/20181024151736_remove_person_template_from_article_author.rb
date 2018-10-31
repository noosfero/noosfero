class RemovePersonTemplateFromArticleAuthor < ActiveRecord::Migration
  def change
    templates = Person.where(is_template: true).ids

    Article.where("author_id in (?)", templates).update_all(author_id: nil)
  end
end
