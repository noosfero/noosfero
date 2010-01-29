class DocController < PublicController

  include LanguageHelper

  no_design_blocks

  before_filter :load_toc

  def index
    @index = DocSection.root(language)
  end

  def section
    @section = DocSection.find(params[:section], language)
  end

  def topic
    @section = DocSection.find(params[:section], language)
    @topic = @section.find(params[:topic])
  end

  protected

  def load_toc
    @toc = DocSection.root(language).find('toc')
  end

end
