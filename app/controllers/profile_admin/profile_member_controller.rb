class ProfileMemberController < ApplicationController

  def index
    @members = @profile.people
  end

  def affiliate
    @member = Person.find(params[:id])
    @roles = Role.find(:all).select{ |r| r.has_kind?(:profile) }
  end

  def give_role
    @person = Person.find(params[:person])
    @role = Role.find(params[:role])
    if @profile.affiliate(@person, @role)
      redirect_to :action => 'index'
    else
      @member = Person.find(params[:person])
      @roles = Role.find(:all).select{ |r| r.has_kind?(:profile) }
      render :action => 'affiliate'
    end
  end
end
