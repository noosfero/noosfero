require 'extended_tag.rb'

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
    @tags = @parent ? @parent.children : Tag.find(:all).select{|t|!t.parent}
    @pending_tags = Tag.find_pendings
  end

  # Prompt to data for a new tag
  def new
    @parent_tags = Tag.find_all
    @tag = Tag.new
  end

  # Collects the data and creates a new tag with it
  def create
    @tag = Tag.new(params[:tag])
    
    if @tag.save
      flash[:notice] = _('Tag was successfully created.')
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  # Prompt for modifications on the attributes of a tag
  def edit
    @tag = Tag.original_find(params[:id])
    @parent_tags = Tag.find_all - @tag.descendents - [@tag]
  end

  # Do the modifications collected by edit
  def update
    @tag = Tag.original_find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = _('Tag was successfully updated.')
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  # Destroy a tag
  def destroy
    @tag = Tag.original_find(params[:id])
    @tag.destroy
    redirect_to :action => 'list'
  end

  def approve
    @tag = Tag.original_find(params[:id])
    @tag.pending = false
    if @tag.save
      flash[:notice] = _('Tag was successfuly approved')
      redirect_to :action => 'list'
    end
  end
end
