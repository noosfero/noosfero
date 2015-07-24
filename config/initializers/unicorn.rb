require_dependency 'noosfero/scheduler/defer'

if defined? Unicorn
  ObjectSpace.each_object Unicorn::HttpServer do |s|
    s.extend Noosfero::Scheduler::Defer::Unicorn
  end
end

