class ManageTagsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @tags = Tag.find_all
  end

  def new
    @tags = Tag.find_all
    @tag = Tag.new
  end

  def create
    @tag = Tag.new
    @tag.name = params[:tag][:name]
    @tag.parent = Tag.find(params[:parent_id].to_i) if params[:parent_id] != "0"
    if @tag.save
      flash[:notice] = _('Tag was successfully created.')
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
end
