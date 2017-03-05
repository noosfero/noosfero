# to run by hand
if $PROGRAM_NAME == __FILE__
  require File.dirname(__FILE__) + '/../config/environment'
end

# This class implements the feed updater. To change how often a feed gets
# updated, change FeedUpdater#update_interval in your config/local.rb file like
# this:
#
#   FeedUpdater.update_interval = 24.hours
#
# You can also customize the time between update runs setting
# FeedUpdater#daemon_sleep_interval. Give it an integer representing the number
# of seconds to wait between runs in your config/local.rb:
#
#   FeedUpdater.daemon_sleep_interval = 10
#
# The feed updaters is controlled by script/feed-updater, which starts and
# stops the process.
class FeedUpdater

  class ExceptionNotification < ActionMailer::Base
    def mail container, error
      environment = Environment.default

      recipients NOOSFERO_CONF['exception_recipients']
      from       environment.noreply_email
      reply_to   environment.noreply_email
      subject    "[#{environment.name}] Feed-updater: #{error.message}"
      body       render(:text => "
Container:
#{container.inspect}

Backtrace:
#{error.backtrace.join("\n")}
      ")
    end
  end

  # indicates how much time one feed will be left without updates
  # (ActiveSupport::Duration). Default: <tt>4.hours</tt>
  cattr_accessor :update_interval
  self.update_interval = 4.hours

  # indicates for how much time the daemon sleeps before looking for new feeds
  # to load (in seconds, an integer). Default: 30
  cattr_accessor :daemon_sleep_interval
  self.daemon_sleep_interval = 30

  attr_accessor :running

  def initialize
    self.running = true
  end

  def start
    ['TERM', 'INT'].each do |signal|
      Signal.trap(signal) do
        stop
        puts "Feed updater exiting gracefully ..."
      end
    end
    puts "Feed updater started."
    run
    puts "Feed updater exited."
  end

  def run
    while running
      process_round
      wait
    end
  end

  def wait
    i = 0
    while running && i < FeedUpdater.daemon_sleep_interval
      sleep 1
      i += 1
    end
  end

  def stop
    self.running = false
  end

  def process_round
    feed_handler = FeedHandler.new
    [FeedReaderBlock, ExternalFeed].each do |source|
      if !running
        break
      end
      source.expired.all.each do |container|
        if !running
          break
        end
        begin
          feed_handler.process(container)
        rescue Exception => e
          FeedUpdater::ExceptionNotification.deliver_mail container, e if NOOSFERO_CONF['exception_recipients'].present?
        end
      end
    end
  end
end

# run the updater
if ($PROGRAM_NAME == __FILE__)
  FeedUpdater.new.start
end
