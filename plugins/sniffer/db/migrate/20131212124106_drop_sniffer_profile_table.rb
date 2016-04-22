SnifferPlugin.send :remove_const, :Opportunity if defined? SnifferPlugin::Opportunity

class SnifferPlugin::Profile < ApplicationRecord
  belongs_to :profile
end
class SnifferPlugin::Opportunity < ApplicationRecord
  belongs_to :sniffer_profile, class_name: 'SnifferPlugin::Profile', foreign_key: :profile_id
end

class DropSnifferProfileTable < ActiveRecord::Migration
  def self.up
    SnifferPlugin::Opportunity.find_each do |opportunity|
      sniffer_profile = opportunity.sniffer_profile
      next unless sniffer_profile.profile

      opportunity.profile_id = sniffer_profile.profile.id
      opportunity.save!
    end

    drop_table :sniffer_plugin_profiles
  end

  def self.down
  end
end
