class Ticket < Task
  acts_as_having_settings :field => :data
  settings_items :title, :description, :closing_statment
end
