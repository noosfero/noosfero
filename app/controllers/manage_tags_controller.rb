require 'extended_tag'

# Manage tags stored by the acts-as_taggable_on_steroids plugin by providing an interface to create, destroy, update and list them
class ManageTagsController < ApplicationController
  # Index redirects to list action without modifing the url
  def index
    list
    render :action => 'list'
  end
  
  # Lists the tags strting with the top tags or with the chidren of @parent if its provided
  def list
    @parent = Tag.find(params[:parent]) if params[:parent]
    @tags = @parent ? @parent.children.select{|t|!t.pending} :  Tag.find_all.select{|t|!t.pending?}
    @pending_tags = Tag.find_all.select(&:pending?)
  end

  # Prompt to data for a new tag
  def new
    @parent_tags = Tag.find_all.select{|t|!t.pending?}
    @tag = Tag.new
  end

  # Collects the data and creates a new tag with it
  def create
    @tag = Tag.new
    @tag.name = params[:tag][:name]
    @tag.parent = Tag.find(params[:parent_id].to_i) if params[:parent_id] != "0"
    @tag.pending = params[:tag][:pending] if params[:tag][:pending]
    if @tag.save
      flash[:notice] = _('Tag was successfully created.')
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  # Prompt for modifications on the attributes of a tag
  def edit
    @tag = Tag.find(params[:id])
    @parent_tags = Tag.find_all.select{|t|!t.pending?} - @tag.descendents - [@tag]
  end

  # Do the modifications collected by edit
  def update
    @tag = Tag.find(params[:id])
    @tag.name = params[:tag][:name]
    @tag.parent = params[:parent_id] != "0" ? Tag.find(params[:parent_id].to_i) : nil
    if @tag.save
      flash[:notice] = _('Tag was successfully updated.')
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  # Destroy a tag
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to :action => 'list'
  end
end
