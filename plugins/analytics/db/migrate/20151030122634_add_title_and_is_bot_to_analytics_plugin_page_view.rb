class AddTitleAndIsBotToAnalyticsPluginPageView < ActiveRecord::Migration

  def up
    add_column :analytics_plugin_page_views, :title, :text
    add_column :analytics_plugin_page_views, :is_bot, :boolean

    # missing indexes for performance
    add_index :analytics_plugin_page_views, :type
    add_index :analytics_plugin_page_views, :visit_id
    add_index :analytics_plugin_page_views, :request_started_at
    add_index :analytics_plugin_page_views, :page_loaded_at
    add_index :analytics_plugin_page_views, :is_bot

    AnalyticsPlugin::PageView.transaction do
      AnalyticsPlugin::PageView.find_each do |page_view|
        page_view.send :fill_is_bot
        page_view.update_column :is_bot, page_view.is_bot
      end
    end

    change_table :analytics_plugin_visits do |t|
      t.timestamps
    end
    AnalyticsPlugin::Visit.transaction do
      AnalyticsPlugin::Visit.find_each do |visit|
        visit.created_at = visit.page_views.first.request_started_at
        visit.updated_at = visit.page_views.last.request_started_at
        visit.save!
      end
    end

    # never used
    remove_column :analytics_plugin_page_views, :track_id
  end

  def down
    say "this migration can't be reverted"
  end

end
