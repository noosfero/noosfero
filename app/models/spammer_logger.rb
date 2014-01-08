class SpammerLogger < Logger
  @logpath = Rails.root.join('log', "#{ENV['RAILS_ENV']}_spammers.log")
  @logger = new(@logpath)

  def self.log(spammer_ip, object=nil)
    if object
      if object.kind_of?(Comment)
        @logger << "[#{Time.now.strftime('%F %T %z')}] Comment-id: #{object.id} IP: #{spammer_ip}\n"
      elsif object.kind_of?(SuggestArticle)
        @logger << "[#{Time.now.strftime('%F %T %z')}] SuggestArticle-id: #{object.id} IP: #{spammer_ip}\n"
      end
    else
        @logger << "[#{Time.now.strftime('%F %T %z')}] IP: #{spammer_ip}\n"
    end
  end

  def self.clean_log
    File.delete(@logpath) if File.exists?(@logpath)
  end

  def self.reload_log
    clean_log
    @logger = new(@logpath)
  end

end
