#!/usr/bin/env rake

require_relative 'config/application'

Noosfero::Application.load_tasks

[
  "baseplugins/*/{tasks,lib/tasks,rails/tasks}/**/*.rake",
  "config/plugins/*/{tasks,lib/tasks,rails/tasks}/**/*.rake",
  "config/plugins/*/vendor/plugins/*/{tasks,lib/tasks,rails/tasks}/**/*.rake",
].map do |pattern|
  Dir.glob(pattern).sort
end.flatten.each do |taskfile|
  load taskfile
end 

