Elasticsearch Plugin
====================

Elasticsearch is as plugin to run searchs in noosfero through elasticsearch.

The Version used is 1.7.5 due compatibility problems with gems and new versions.

Download: https://www.elastic.co/downloads/past-releases/elasticsearch-1-7-5

INSTALL
=======

Install dependencies

Install elasticsearch package and start service.
By default, the service runs on port 9200

Install gems listed in plugin Gemfile. If this step fail, just copy the gems to core Gemfile
and run the command 'bundle install'

Enable plugin
-------------

Execute the command to enable Elasticsearch Plugin at your noosfero:

./script/noosfero-plugins enable elasticsearch

Active plugin
-------------

As a Noosfero administrator user, go to administrator panel:

- Click on "Enable/disable plugins" option
- Click on "Elasticsearch" check-box

DEVELOPMENT
===========

To run  tests for Elasticsearch:

Use command 'rspec'
