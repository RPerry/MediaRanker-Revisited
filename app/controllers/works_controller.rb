class WorksController < ApplicationController
  # We should always be able to tell what category
  # of work we're dealing with
  before_action :require_login, only: [:index, :show]
  before_action :category_from_work, except: [:root, :index, :new, :create]

  def root
    @albums = Work.best_albums
    @books = Work.best_books
    @movies = Work.best_movies
    @best_work = Work.order(vote_count: :desc).first
  end

  def index
    @works_by_category = Work.to_category_hash
  end

  def new
    @work = Work.new
  end

  def create
    @work = Work.new(media_params)
    @media_category = @work.category
    if @work.save
      flash[:status] = :success
      flash[:message] = "Successfully created #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash[:status] = :failure
      flash[:message] = "Could not create #{@media_category.singularize}"
      flash[:messages] = @work.errors.messages
      render :new, status: :bad_request
    end
  end

  def show
  
    @votes = @work.votes.order(created_at: :desc)

  end

  def edit
  end

  def update
    @work.update_attributes(media_params)
    if @work.save
      flash[:status] = :success
      flash[:message] = "Successfully updated #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash.now[:status] = :failure
      flash.now[:message] = "Could not update #{@media_category.singularize}"
      flash.now[:messages] = @work.errors.messages
      render :edit, status: :not_found
    end
  end

  def destroy
    @work.destroy
    flash[:status] = :success
    flash[:message] = "Successfully destroyed #{@media_category.singularize} #{@work.id}"
    redirect_to root_path
  end

  def upvote
    flash[:status] = :failure
    if @login_user
      vote = Vote.new(user: @login_user, work: @work)
      if vote.save
        flash[:status] = :success
        flash[:message] = "Successfully upvoted!"
      else
        flash[:message] = "Could not upvote"
        flash[:message] = vote.errors.messages
      end
    else
      flash[:message] = "You must log in to do that"
    end

    # Refresh the page to show either the updated vote count
    # or the error message
    redirect_back fallback_location: work_path(@work)
  end

  private

  def media_params
    params.require(:work).permit(:title, :category, :creator, :description, :publication_year)
  end

  def category_from_work
    @work = Work.find_by(id: params[:id])
    render_404 unless @work
    @media_category = @work.category.downcase.pluralize
  end
end
