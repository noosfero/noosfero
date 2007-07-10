require 'extended_tag'
class ManageTagsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @parent = Tag.find(params[:parent]) if params[:parent]
    @tags = Tag.find_all_by_parent_id(params[:parent]).select{|t|!t.pending?}
    @pending_tags = Tag.find_all.select(&:pending?)
  end

  def new
    @parent_tags = Tag.find_all
    @tag = Tag.new
  end

  def create
    @tag = Tag.new
    @tag.name = params[:tag][:name]
    @tag.parent = Tag.find(params[:parent_id].to_i) if params[:parent_id] != "0"
    @tag.pending = params[:tag][:pending]
    if @tag.save
      flash[:notice] = _('Tag was successfully created.')
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    @parent_tags = Tag.find_all - @tag.descendents - [@tag]
  end

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

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to :action => 'list'
  end
end
