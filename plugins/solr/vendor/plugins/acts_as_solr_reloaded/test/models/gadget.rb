class Gadget < ActiveRecord::Base
  cattr_accessor :search_disabled

  acts_as_solr :offline => proc {|record| Gadget.search_disabled?}, :results_format => :ids

  def self.search_disabled?
    search_disabled
  end
end
