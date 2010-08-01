module Noosfero
  module SQL
    class << self

      def random_function()
        default = 'random()'
        adapter = ActiveRecord::Base.configurations[Rails.env]['adapter']
        {
          'mysql' => 'rand()'
        }[adapter] || default
      end

    end
  end
end
