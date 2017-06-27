class UpdateSuggestArticleData < ActiveRecord::Migration
  def change
    say_with_time "Updating suggest article datas..." do
      SuggestArticle.pending.find_each do |suggest_article|
          if suggest_article.data[:article_body].present?
            article = {name: suggest_article.data[:article_name],
                        source_name: suggest_article.data[:source_name],
                        source: suggest_article.data[:source],
                        abstract: suggest_article.data[:article_abstract],
                        body: suggest_article.data[:article_body]
                      }
            suggest_article.data[:article] = article

            [:article_name, :source_name, :source, :article_abstract, :article_body].each do |key|
              suggest_article.data.delete(key)
            end

            suggest_article.save!
          end
      end
    end
  end
end
