class UpdateSuggestArticleData < ActiveRecord::Migration
  def change
  say_with_time "Updating suggest article datas..." do
    Task.all.each do |task|
       if task.type == "SuggestArticle" && task.data[:article].nil?
         data = task.data
         article = []
         article = {:name => data[:article_name],
                  :source_name => data[:source_name],
                  :source => data[:source],
                  :abstract => data[:article_abstract],
                  :body => data[:article_body]
                }
         task.data = {:article => article}
         task.save
       end
    end
  end
  end
end
