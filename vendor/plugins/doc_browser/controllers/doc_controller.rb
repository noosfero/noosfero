require 'doc_browser'

# Controller for serving documentation installed in a Rails application
class DocController < ApplicationController

  self.template_root = File.join(File.dirname(__FILE__), '..', 'views')

  layout 'doc'

  def index
    @docs = DocBrowser.find_docs
    @errors = DocBrowser.errors
  end

end
