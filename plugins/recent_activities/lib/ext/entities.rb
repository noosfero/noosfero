require_dependency 'api/entities'

module Api
  module Entities
    class Activity
      expose :label
      expose :start_date do |activity|
        activity.target.start_date if activity.target.is_a?(Event)
      end
    end
  end
end
