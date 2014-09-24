begin
  require 'jeweler'
rescue LoadError
end

Jeweler::Tasks.new do |s|
  s.name = "acts_as_solr_reloaded"
  s.summary = "This gem adds full text search capabilities and many other nifty features from Apache Solr to any Rails model."
  s.email = "dc.rec1@gmail.com"
  s.homepage = "http://github.com/dcrec1/acts_as_solr_reloaded"
  s.description = "This gem adds full text search capabilities and many other nifty features from Apache Solr to any Rails model."
  s.authors = ["Diego Carrion"]
  s.files =  FileList["[A-Z]*", "{bin,generators,config,lib,solr}/**/*"] +
    FileList["test/**/*"].reject {|f| f.include?("test/log")}.reject {|f| f.include?("test/tmp")}
end if defined? Jeweler
