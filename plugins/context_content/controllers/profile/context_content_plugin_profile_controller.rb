class ContextContentPluginProfileController < ProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def view_content
    block = Block.find(params[:id])
    p = params[:page].to_i
    contents = block.contents(profile.articles.find(params[:article_id]), p)

    if contents
      @page = Article.find(params[:article_id])
      @block = block
      @direction = params[:direction]

      respond_to do |format|
        format.js
      end
    else
      render plain: "Invalid page", :status => 500
    end
   end
end
