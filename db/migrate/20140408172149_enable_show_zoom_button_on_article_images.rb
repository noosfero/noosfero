class EnableShowZoomButtonOnArticleImages < ActiveRecord::Migration
  def self.up
    Environment.find_each do |environment|
      environment.enable(:show_zoom_button_on_article_images) 
    end
  end

  def self.down
    say("This migration is irreversible.")
  end
end
