# Manage tags stored by the acts-as_taggable_on_steroids plugin by providing an interface to create, destroy, update and list them
class ManageTagsController < ApplicationController

  # Index redirects to list action without modifing the url
  def index
    redirect_to :action => 'list'
  end
  
  # Lists the tags starting with the top tags or with the chidren of @parent if its provided
  def list
    @parent = Tag.find(params[:parent]) if params[:parent]
    @tags = @parent ? @parent.children : Tag.roots
    @pending_tags = Tag.find_pendings
  end

  # Prompt for data to a new tag
  def new
    @parent_tags = Tag.find(:all)
    @tag = Tag.new
  end

  # Collects the data and creates a new tag with it
  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = _('Tag was successfully created.')
      redirect_to :action => 'list'
    else
      @parent_tags = Tag.find(:all)
      render :action => 'new'
    end
  end

  # Prompt for modifications on the attributes of a tag
  def edit
    @tag = Tag.find_with_pendings(params[:id])
    @parent_tags = @tag.parent_candidates
  end

  # Do the modifications collected by edit
  def update
    @tag = Tag.find_with_pendings(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = _('Tag was successfully updated.')
      redirect_to :action => 'list'
    else
      @parent_tags = @tag.parent_candidates
      render :action => 'edit'
    end
  end

  # Destroy a tag and all its children
  def destroy
    @tag = Tag.find_with_pendings(params[:id])
    if @tag.destroy
      flash[:notice] = _('Tag was successfuly destroyed')
    end
    redirect_to :action => 'list'
  end

  # Approve a pending tag so now ita can be used to tag things
  def approve
    @tag = Tag.find_with_pendings(params[:id])
    if @tag.update_attribute(:pending, false)
      flash[:notice] = _('Tag was successfuly approved')
      redirect_to :action => 'list'
    end
  end

  # Full-text search for tags that have the query terms
  def search
    @tags_found = Tag.find_by_contents(params[:query])
  end
end
