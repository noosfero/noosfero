class AddBlockToEnvironmentAndProfile < ActiveRecord::Migration
    def up
      Environment.all.each do |env|
        env.boxes << Box.new if env.boxes.count < 4
      end

      Profile.all.each do |profile|
        profile.boxes << Box.new if profile.boxes.count < 4
      end
    end

    def down
      say "this migration can't be reverted"
    end
end
