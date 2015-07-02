# ActsAsVoter
module PeteOnRails
  module Acts #:nodoc:
    module Voter #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_voter
          has_many :votes, :as => :voter, :dependent => :nullify  # If a voting entity is deleted, keep the votes.
          include PeteOnRails::Acts::Voter::InstanceMethods
          extend  PeteOnRails::Acts::Voter::SingletonMethods
        end
      end

      # This module contains class methods
      module SingletonMethods
      end

      # This module contains instance methods
      module InstanceMethods

        # Usage user.vote_count(true)  # All +1 votes
        #       user.vote_count(false) # All -1 votes
        #       user.vote_count()      # All votes
        #
        def vote_count(for_or_against = "all")
          return self.votes.size if for_or_against == "all"
          self.votes.where(vote: if for_or_against then 1 else -1 end).count
        end

        def voted_for?(voteable)
          voteable.voted_by?(self, true)
        end

        def voted_against?(voteable)
          voteable.voted_by?(self, false)
        end

        def voted_on?(voteable)
          voteable.voted_by?(self)
        end

        def vote_for(voteable)
          self.vote(voteable, 1)
        end

        def vote_against(voteable)
          self.vote(voteable, -1)
        end

        def vote(voteable, vote)
          Vote.create(:vote => vote, :voteable => voteable, :voter => self).tap do |v|
            voteable.reload_vote_counter if !v.new_record? and voteable.respond_to?(:reload_vote_counter)
          end.errors.empty?
        end

      end

    end

  end
end
