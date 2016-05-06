require File.join(Rails.root,'lib','noosfero','api','entities')
module Noosfero
  module API
    module Entities
      class Block < Entity
        available_counters = (StatisticsBlock::USER_COUNTERS + StatisticsBlock::COMMUNITY_COUNTERS + StatisticsBlock::ENTERPRISE_COUNTERS).uniq

        available_counters.each do |counter_attr|
          expose counter_attr, :if => lambda{|block,options| block.respond_to?(counter_attr) && block.is_counter_available?(counter_attr)}

          counter_method = counter_attr.to_s.gsub('_counter','').pluralize.to_sym
          expose counter_method, :if => lambda { |block,options|
            block.respond_to?(counter_method) && block.is_visible?(counter_attr)
          }
        end

      end
    end
  end
end

