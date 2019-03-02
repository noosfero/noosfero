class RemoveEmptyCustomFieldsFromArticles < ActiveRecord::Migration[5.1]
  def change
    Article.find_each do |article|
        if article.metadata.has_key?('custom_fields') && article.metadata['custom_fields'].empty?
            article.metadata.delete('custom_fields')
            article.save
        end
    end
  end
end
