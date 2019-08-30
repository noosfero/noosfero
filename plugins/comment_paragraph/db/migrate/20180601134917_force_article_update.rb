class ForceArticleUpdate < ActiveRecord::Migration[5.1]
  def change
    CommentParagraphPlugin::Discussion.find_each do |article|
      article.body = article.body.to_s + " "
      article.save
    end
  end
end
