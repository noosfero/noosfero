2010-03-08
==========
* Vote method in `acts_as_voter` model returns true upon success. 

2010-02-21
==========
* Changed the `tally` method to add support for `at_least_total` and `at_most_total` parameters to filter by sum of votes.
* Changed the `tally` method to add support for `total` column in :order paramter.

2010-02-20
==========
* Changed the data-type of the `vote` column in the `votes` table to integer type.
* Added support for vote count caching at the `voteable` model.
* Added new method `votes_total` on `voteable` model to return the sum of +ve and -ve votes
* Optimized several methods in `voteable` model (`voters_who_voted`, `voted_by?`)
* Cleaned the code to use associations instead of direct SQL

2009-02-11
==========
* Merge in xlash's bugfix for PostgreSQL and his has\_karma patch for multi-model support. 

2008-12-02
==========
* Merge in maddox's README typo fix and his ActiveSupport.Dependency patch
* Merge in nagybence's updates that make the code usable as a Gem in addition to being a Rails plugin. 
* Thanks for the bugfixes and proofreading, nagybence and maddox!
* Updated the gemplugin support to be compatible with maddox and nagybence's changes. 
* Added details on the MyQuotable reference application. 

2008-07-20
==========
* Protect against mass assignment misvotes using attr\_accessible
* Update acts\_as mixins to use self.class.name instead of the deprecated self.type.name

2008-07-15
==========
* Added examples directory
* Changed this file to markdown format for GitHub goodness
* Added a commented out unique index in the migration generator for "one person, one vote"
* Removed votes\_controller.rb from lib/ and moved to examples

2008-07-10
==========

* Added a generator class for the migration. 
* Implemented rails/init.rb
* Implemented capability to use any model as the initiator of votes.
* Implemented acts\_as\_voter methods.
