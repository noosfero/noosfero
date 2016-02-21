class CreateTemplates < ActiveRecord::Migration
  def self.up
    Environment.find_each do |env|
      if env.person_template.nil? && env.community_template.nil? && env.enterprise_template.nil?
        env.create_templates
      end
    end
  end

  def self.down
    # nothing
  end
end
