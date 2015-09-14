# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"

every 1.day do
  runner "SearchTerm.calculate_scores"
end

every 30.days do
  runner "ProfileSuggestion.generate_all_profile_suggestions"
end

# Loads "schedule.rb" files from plugins
#
# Allows Noosfero's plugins schedule jobs using `whenever` Ruby gem the same
# way we do here, just create the file "config/schedule.rb" into the plugin
# root directory and write jobs using the same syntax used here (see example in
# the `newsletter` plugin)

Dir.glob("config/plugins/*/config/schedule.rb").each do |filename|
  filecontent = IO.read(filename)
  instance_eval(Whenever::NumericSeconds.process_string(filecontent), filename)
end
