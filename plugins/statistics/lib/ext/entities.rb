require_dependency 'api/entities'

module Api
  module Entities
    class Block
      available_counters = (StatisticsBlock::USER_COUNTERS + StatisticsBlock::COMMUNITY_COUNTERS + StatisticsBlock::ENTERPRISE_COUNTERS).uniq
      expose :statistics, :if => lambda { |block, options| block.is_a? StatisticsBlock } do |block, options|
        statistics = []
        available_counters.each do |counter_attr|
          counter_method = counter_attr.to_s.gsub('_counter','').pluralize.to_sym
          counter = {
              name:  counter_method,
              display: block.is_counter_available?(counter_attr) && block.is_visible?(counter_attr),
              quantity: (block.respond_to?(counter_method) && block.is_visible?(counter_attr)) ? block.send(counter_method) :  nil
          }
          statistics << counter
        end
        statistics
      end

    end
  end
end
