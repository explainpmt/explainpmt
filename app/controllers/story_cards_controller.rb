class StoryCardsController < ApplicationController
  model :story_card, :project
  before_filter :check_authentication

  def show
    @story_card = StoryCard.find(params[:id])
  end

  def new
    @story_card = StoryCard.new
  end

  def create
    @project = Project.find(params[:project_id])
    @story_card = StoryCard.new(params[:story_card])
    @story_card.project = @project
    if @story_card.save
      flash[:notice] = 'Story card was successfully created.'
      redirect_to :action => 'show', :id => @story_card.id
    else
      render :action => 'new'
    end
  end
end
