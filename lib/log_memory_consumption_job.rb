class LogMemoryConsumptionJob < Struct.new(:last_stat)
  # Number of entries do display
  N = 20

  def perform
    logpath = File.join(Rails.root, 'log', "#{ENV['RAILS_ENV']}_memory_consumption.log")
    logger = Logger.new(logpath)
    stats = Hash.new(0)
    ObjectSpace.each_object {|o| stats[o.class.to_s] += 1}
    i = 1

    logger << "[#{Time.now.strftime('%F %T %z')}]\n"
    stats.sort {|(k1,v1),(k2,v2)| v2 <=> v1}.each do |k,v|
      logger << (sprintf "%-60s %10d", k, v)
      logger << (sprintf " | delta %10d", (v - last_stat[k])) if last_stat && last_stat[k]
      logger << "\n"
      break if i > N
      i += 1
    end
    logger << "\n"
  end
end
