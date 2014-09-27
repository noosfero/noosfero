require 'acts_as_voteable'
require 'acts_as_voter'
require 'has_karma'
require 'models/vote.rb'

ActiveRecord::Base.send(:include, Juixe::Acts::Voteable)
ActiveRecord::Base.send(:include, PeteOnRails::Acts::Voter)
ActiveRecord::Base.send(:include, PeteOnRails::VoteFu::Karma)
Rails.logger.info "** vote_fu: initialized properly."
