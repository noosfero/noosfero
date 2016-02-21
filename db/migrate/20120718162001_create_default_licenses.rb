class CreateDefaultLicenses < ActiveRecord::Migration
  def self.up
    Environment.all.each do |environment|
      License.create!(:name => 'CC (by)', :url => 'http://creativecommons.org/licenses/by/3.0/legalcode', :environment => environment)
      License.create!(:name => 'CC (by-nd)', :url => 'http://creativecommons.org/licenses/by-nd/3.0/legalcode', :environment => environment)
      License.create!(:name => 'CC (by-sa)', :url => 'http://creativecommons.org/licenses/by-sa/3.0/legalcode', :environment => environment)
      License.create!(:name => 'CC (by-nc)', :url => 'http://creativecommons.org/licenses/by-nc/3.0/legalcode', :environment => environment)
      License.create!(:name => 'CC (by-nc-nd)', :url => 'http://creativecommons.org/licenses/by-nc-nd/3.0/legalcode', :environment => environment)
      License.create!(:name => 'CC (by-nc-sa)', :url => 'http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode', :environment => environment)
      License.create!(:name => 'Free Art', :url => 'http://artlibre.org/licence/lal/en', :environment => environment)
      License.create!(:name => 'GNU FDL', :url => 'http://www.gnu.org/licenses/fdl-1.3.txt', :environment => environment)
    end
  end

  def self.down
    licenses = []
    licenses += License.where name: 'CC (by)'
    licenses += License.where name: 'CC (by-nd)'
    licenses += License.where name: 'CC (by-sa)'
    licenses += License.where name: 'CC (by-nc)'
    licenses += License.where name: 'CC (by-nc-nd)'
    licenses += License.where name: 'CC (by-nc-sa)'
    licenses += License.where name: 'Free Art'
    licenses += License.where name: 'GNU FDL'
    licenses.compact.map(&:destroy)
  end
end
