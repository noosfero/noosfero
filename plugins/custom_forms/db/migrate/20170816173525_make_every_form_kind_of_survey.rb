class MakeEveryFormKindOfSurvey < ActiveRecord::Migration
  def change
    execute("UPDATE custom_forms_plugin_forms SET kind = 'survey';")
  end
end
