class AddMoreTrustedSitesForEnvironments < ActiveRecord::Migration
  def self.up
    default_sites = Environment.new.trusted_sites_for_iframe
    Environment.all.each do |env|
      env.trusted_sites_for_iframe += default_sites
      env.trusted_sites_for_iframe.uniq!
      env.save_without_validation
    end
  end

  def self.down
    say 'Warning: This migration cant recover old data'
  end
end
