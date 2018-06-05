class ForceArticleUpdate < ActiveRecord::Migration
  def change
    CommentParagraphPlugin::Discussion.find_each do |article|
      article.body = article.body + ' '
      article.save
    end
  end
end
