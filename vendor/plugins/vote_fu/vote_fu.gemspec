Gem::Specification.new do |s|
  s.name = "kandadaboggu-vote_fu"
  s.version = "0.0.15"
  s.date = "2010-03-08"
  s.summary = "Enhanced vote_fu with numerical voting and total vote caching."
  s.email = "kandadaboggu@gmail.com"
  s.homepage = "http://github.com/kandadaboggu/vote_fu"
  s.description = "Enhanced vote_fu with numerical voting and total vote caching."
  s.has_rdoc = false
  s.authors = ["Peter Jackson", "Cosmin Radoi", "Bence Nagy", "Rob Maddox", "Kandada Boggu"]
  s.files = [ "CHANGELOG.markdown",
              "MIT-LICENSE",
              "README.markdown",
              "generators/vote_fu",
              "generators/vote_fu/vote_fu_generator.rb",
              "generators/vote_fu/templates",
              "generators/vote_fu/templates/migration.rb",
              "init.rb",
              "lib/vote_fu.rb",
              "lib/acts_as_voteable.rb",
              "lib/acts_as_voter.rb",
              "lib/has_karma.rb",
              "lib/models/vote.rb",
              "lib/controllers/votes_controller.rb",
              "test/vote_fu_test.rb",
              "examples/votes_controller.rb",
              "examples/users_controller.rb",
              "examples/voteables_controller.rb",
              "examples/voteable.rb",
              "examples/voteable.html.erb",
              "examples/votes/_voteable_vote.html.erb",
              "examples/votes/create.rjs",
              "examples/routes.rb", 
              "rails/init.rb"
  ]
end
