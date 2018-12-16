class MakeEveryFormKindOfSurvey < ActiveRecord::Migration[5.1]
  def change
    execute("UPDATE custom_forms_plugin_forms SET kind = 'survey';")
  end
end
