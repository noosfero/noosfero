require File.join(File.dirname(__FILE__), 'rails', 'init')

config.after_initialize do
  Delayed::Worker.guess_backend
end
