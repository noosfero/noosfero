class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :mezuro_plugin_projects do |t|
      t.string      :name
      t.string      :identifier
      t.string      :personal_webpage
      t.text        :description
      t.string      :repository_url
      t.string      :svn_error
      t.boolean     :with_tab
      t.references  :profile

      t.timestamps
    end
  end

  def self.down
    drop_table :mezuro_plugin_projects
  end
end
