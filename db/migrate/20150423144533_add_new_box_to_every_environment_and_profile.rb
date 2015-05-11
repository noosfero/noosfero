class AddNewBoxToEveryEnvironmentAndProfile < ActiveRecord::Migration
    def up
      Environment.find_each do |env|
        env.boxes << Box.new if env.boxes.count < 4
      end

      Profile.find_each do |profile|
        profile.boxes << Box.new if profile.boxes.count < 4
      end
    end

    def down
      say "this migration can't be reverted"
    end
end
