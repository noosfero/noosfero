class InitAnalyticsPlugin < ActiveRecord::Migration

  def up
    create_table :analytics_plugin_visits do |t|
      t.integer :profile_id
    end

    create_table :analytics_plugin_page_views do |t|
      t.string :type
      t.integer :visit_id
      t.integer :track_id
      t.integer :referer_page_view_id
      t.string :request_id

      t.integer :user_id
      t.integer :session_id
      t.integer :profile_id

      t.text :url
      t.text :referer_url

      t.text :user_agent
      t.string :remote_ip

      t.datetime :request_started_at
      t.datetime :request_finished_at
      t.datetime :page_loaded_at
      t.integer :time_on_page, default: 0

      t.text :data, default: {}.to_yaml
    end
    add_index :analytics_plugin_page_views, :request_id
    add_index :analytics_plugin_page_views, :referer_page_view_id

    add_index :analytics_plugin_page_views, :user_id
    add_index :analytics_plugin_page_views, :session_id
    add_index :analytics_plugin_page_views, :profile_id
    add_index :analytics_plugin_page_views, :url
    add_index :analytics_plugin_page_views, [:user_id, :session_id, :profile_id, :url], name: :analytics_plugin_referer_find
  end

  def down
    drop_table :analytics_plugin_visits
    drop_table :analytics_plugin_page_views
  end

end
